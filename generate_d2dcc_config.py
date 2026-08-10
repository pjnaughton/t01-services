import polars as pl
from string import Template
import sys



SIC_STRING = """

  - NAME: $magnet_name
    FPGA_TYPE: $fpga_type
    FPGA_TYPE_NUMBER: $fpga_type_number"""

FRC_STRING = SIC_STRING + """
    MAGNET_ONE: $magnet_one
    MAGNET_TWO: $magnet_two
    MAGNET_THREE: $magnet_three
    MAGNET_FOUR: $magnet_four
    """

SIC_TEMPLATE = Template(SIC_STRING)
FRC_TEMPLATE = Template(FRC_STRING)

file = open(
    "/scratch/ygn40972/repos/tutorials/t01-services/services/CIA-1/values.yaml", "a"
)


def parse_type_number(value):
    return 123


PSU_CONTROLER_TABLE = {
    "OCEM 200A MODULE": "SIC_DPS",
    "DLS 200A MODULE": "SIC_DPS",
    "SC (SIC controller) ": "SIC_DPS",
    "FOFB SC": "SOFB",
    "SC (PSI controller) ": "SIC_DPS",
    "FOFB FC": "FOFB",
    "DLS 50A MODULE": "SIC_DPS",
}


def writer(file, template, **data):
    file.write(template.substitute(data))


spreadsheet_filepath = "/scratch/ygn40972/repos/tutorials/t01-services/Magnet to Epics end-to-end connections V04.xlsx"
controller_card_str = "PSI Controller card"
df = pl.read_excel(
    spreadsheet_filepath,
    sheet_name="CIA 01",
    engine="xlsx2csv",
    engine_options={"skip_empty_lines": True},
    schema_overrides={"Current rating (A)": pl.Utf8},
    read_options={
        "has_header": True,
        "skip_rows": 2,
        "columns": [
            0,  # Magnet ID
            41,  # PSU Type
            47,  # (FRC magnet number)
        ],
        "new_columns": [
            "Magnet ID",
            "PSU Type",
            "FRC Magnet Number",
        ],
    },
)

magnet_sive = pl.any_horizontal(pl.col("Magnet ID").str.starts_with("SR"))
magnet_controlers = df.filter(magnet_sive)
magnet_controlers = magnet_controlers.filter(
    pl.any_horizontal(pl.col("PSU Type").is_not_null())
)

sic_controllers = magnet_controlers.filter(
    pl.col("PSU Type").is_in(
        [key for key, value in PSU_CONTROLER_TABLE.items() if value == "SIC"]
    )
)

frc_controllers = magnet_controlers.filter(
    pl.col("PSU Type").is_in(
        [
            key
            for key, value in PSU_CONTROLER_TABLE.items()
            if (value == "FOFB" or value == "SOFB")
        ]
    )
)


for data in sic_controllers.iter_rows(named=True):
    file.write(
        SIC_TEMPLATE.substitute(
            magnet_name=data["Magnet ID"],
            fpga_type=PSU_CONTROLER_TABLE[data["PSU Type"]],
            fpga_type_number=parse_type_number(data["PSU Type"]))
    )

frc_group = frc_controllers.group_by(
    pl.col("FRC Magnet Number").round(0), maintain_order=True
)

magnet_list = ["magnet_one", "magnet_two", "magnet_three", "magnet_four"]
for _, data in frc_group:
    magnet_names = {}
    frc_type = set()
    for magnet_index, magnet_controller in enumerate(data.iter_rows(named=True)):
        magnet_names[magnet_list[magnet_index]] = magnet_controller["Magnet ID"]
        frc_type.add(PSU_CONTROLER_TABLE[magnet_controller["PSU Type"]])

    assert len(set(magnet_names.values())) == len(
        data
    ), "All FRC Magnet names must be unique"

    assert len(frc_type) == 1, "All FRC magnet types must be the same"
    file.write(
        FRC_TEMPLATE.substitute(
            magnet_name=magnet_names["magnet_one"],
            fpga_type=frc_type.pop(),
            fpga_type_number=123,
            **magnet_names)
    )
