#!/usr/bin/env python


"""Provide a command line tool to validate and transform tabular samplesheets."""


import argparse
import csv
import logging
import sys
from collections import Counter
from pathlib import Path

logger = logging.getLogger()


class RowChecker:
    """
    Define a service that can validate and transform each given row.

    Attributes:
        modified (list): A list of dicts, where each dict corresponds to a previously
            validated and transformed row. The order of rows is maintained.

    """

    VALID_FORMATS = (
        ".bam"
    )

    def __init__(
        self,
        pairId="pairId",
        tumorBam="tumorBam",
        normalBam="normalBam",
        assay="assay",
        normalType="normalType",
        bedFile="bedFile",
        **kwargs,
    ):
        """
        Initialize the row checker with the expected column names.

        Args:


        """
        super().__init__(**kwargs)
        self._pairId=pairId
        self._tumorBam=tumorBam
        self._normalBam=normalBam
        self._assay=assay
        self._normalType=normalType
        self._bedFile=bedFile
        self._seen = set()
        self.modified = []

    def validate_and_transform(self, row):
        """
        Perform all validations on the given row and insert the read pairing status.

        Args:
            row (dict): A mapping from column headers (keys) to elements of that row
                (values).

        """
        self._validate_names(row)
        self._validate_bams(row)
        self._validate_normalType(row)
        self._validate_bed_format(row)
        self._seen.add((row[self._pairId]))
        self.modified.append(row)

    def _validate_names(self, row):
        """Assert that the sample names exist"""
        if len(row[self._pairId]) <= 0:
            raise AssertionError("pairId is required.")

    def _validate_pairId_format(self, row):
        id_value = row[self._pairId]
        if "." in id_value:
            raise AssertionError("pairId:{} cannot contain any periods ('.') ".format(id_value))

    def _validate_bams(self, row):
        """Assert that the first FASTQ entry is non-empty and has the right format."""
        if len(row[self._tumorBam]) <= 0  or len(row[self._normalBam]) <= 0:
            raise AssertionError("Both bam files are required.")
        self._validate_bam_format(row[self._tumorBam])
        self._validate_bam_format(row[self._normalBam])

    def _validate_normalType(self, row):
        """Assert that bait set exists."""
        if len(row[self._normalType]) <= 0:
            raise AssertionError("normalType is required.")

    def _validate_bam_format(self, filename):
        """Assert that a given filename has one of the expected FASTQ extensions."""
        if not any(filename.endswith(extension) for extension in self.VALID_FORMATS):
            raise AssertionError(
                f"The BAM file has an unrecognized extension: {filename}\n"
                f"It should be one of: {', '.join(self.VALID_FORMATS)}"
            )

    def _validate_bed_format(self, row):
        """Assert that a given filename has one of the expected BED extensions."""
        filename = row[self._bedFile]
        if filename and filename != "NONE":
            if not filename.endswith(".bed"):
                raise AssertionError(
                    f"The BED file has an unrecognized extension: {filename}\n"
                    f"It should be .bed\n"
                    f"If you would like one generated for you leave it bank or enter 'NONE'\n"
                )


def read_head(handle, num_lines=10):
    """Read the specified number of lines from the current position in the file."""
    lines = []
    for idx, line in enumerate(handle):
        if idx == num_lines:
            break
        lines.append(line)
    return "".join(lines)


def sniff_format(handle):
    """
    Detect the tabular format.

    Args:
        handle (text file): A handle to a `text file`_ object. The read position is
        expected to be at the beginning (index 0).

    Returns:
        csv.Dialect: The detected tabular format.

    .. _text file:
        https://docs.python.org/3/glossary.html#term-text-file

    """
    peek = read_head(handle)
    handle.seek(0)
    sniffer = csv.Sniffer()
    dialect = sniffer.sniff(peek)
    return dialect


def check_samplesheet(file_in, file_out):
    """
    Check that the tabular samplesheet has the structure expected by the ODIN pipeline.

    Validate the general shape of the table, expected columns, and each row.

    Args:
        file_in (pathlib.Path): The given tabular samplesheet. The format can be either
            CSV, TSV, or any other format automatically recognized by ``csv.Sniffer``.
        file_out (pathlib.Path): Where the validated and transformed samplesheet should
            be created; always in CSV format.

    Example:
        This function checks that the samplesheet follows the following structure,
        see also the `viral recon samplesheet`_::

            pairId,tumorBam,normalBam,assay,normalType,bedFile
            SAMPLE_TUMOR.SAMPLE_NORMAL,BAM_TUMOR,BAM_NORMAL,BAITS,NORMAL_TYPE,BED_FILE

    """
    required_columns = {"pairId","tumorBam","normalBam","assay","normalType","bedFile"}
    # See https://docs.python.org/3.9/library/csv.html#id3 to read up on `newline=""`.
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle, dialect=sniff_format(in_handle),delimiter=',')
        # Validate the existence of the expected header columns.
        if not required_columns.issubset(reader.fieldnames):
            req_cols = ", ".join(required_columns)
            logger.critical(f"The sample sheet **must** contain these column headers: {req_cols}.")
            sys.exit(1)
        # Validate each row.
        checker = RowChecker()
        for i, row in enumerate(reader):
            try:
                checker.validate_and_transform(row)
            except AssertionError as error:
                logger.critical(f"{str(error)} On line {i + 2}.")
                sys.exit(1)
    header = list(reader.fieldnames)
    # See https://docs.python.org/3.9/library/csv.html#id3 to read up on `newline=""`.
    with file_out.open(mode="w", newline="") as out_handle:
        writer = csv.DictWriter(out_handle, header, delimiter=",")
        writer.writeheader()
        for row in checker.modified:
            writer.writerow(row)


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument(
        "file_in",
        metavar="FILE_IN",
        type=Path,
        help="Tabular input samplesheet in CSV or TSV format.",
    )
    parser.add_argument(
        "file_out",
        metavar="FILE_OUT",
        type=Path,
        help="Transformed output samplesheet in CSV format.",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"The given input file {args.file_in} was not found!")
        sys.exit(2)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_samplesheet(args.file_in, args.file_out)


if __name__ == "__main__":
    sys.exit(main())
