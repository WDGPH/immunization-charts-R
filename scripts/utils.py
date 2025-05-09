import typst
from datetime import date, datetime

def calculate_age(DOB, DOV):

    """
    Calculate age in full years and months between a date of birth and a given date.

    Parameters:
        DOB (str): Date of birth in the format "YYYY-MM-DD".
        DOV (str): Date of visit in the format "Mon DD, YYYY" (e.g., "May 8, 2025").

    Returns:
        str: Age formatted as "XY XM", where Y is years and M is months.
    
    Example:
        calculate_age("2009-09-08", "May 8, 2025") -> "15Y 8M"
    """

    DOB_datetime = datetime.strptime(DOB, "%Y-%m-%d")
    DOV_datetime = datetime.strptime(DOV, "%b %d, %Y")

    years = DOV_datetime.year - DOB_datetime.year
    months = DOV_datetime.month - DOB_datetime.month

    # Adjust if birthday hasn't occurred yet in the DOV month
    if DOV_datetime.day < DOB_datetime.day:
        months += 1

    # If months became negative, adjust year and add 12 to months
    if months < 0:
        years -= 1 
        months += 12 

    return(f"{years}Y {months}M")


def compile_typst(immunization_record, outpath):

    typst.compile(immunization_record, output = outpath)


# template_path = sys.argv[1]
# compile_typst(template_path, "../output/test.pdf")