import typst
from datetime import datetime

def convert_date_string(date_str):
    """
    Convert a date string from "YYYY-MM-DD" format to "Mon DD, YYYY".

    Parameters:
        date_str (str): Date in the format "YYYY-MM-DD" (e.g., "2025-05-08").
    
    Returns:
        str: Date in the format "Mon DD, YYYY".

    Example:
        convert_date_string("2025-05-08") -> "May 8, 2025"
    """

    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    return date_obj.strftime("%b %d, %Y")

def convert_date_iso(date_str):
    """
    Convert a date string from "Mon DD, YYYY" format to "YYYY-MM-DD".

    Parameters:
        date_str (str): Date in the format "Mon DD, YYYY" (e.g., "May 8, 2025").

    Returns:
        str: Date in the format "YYYY-MM-DD".

    Example:
        convert_date("May 8, 2025") -> "2025-05-08"
    """
    date_obj = datetime.strptime(date_str, "%b %d, %Y")
    return date_obj.strftime("%Y-%m-%d")

def over_16_check(date_of_birth, delivery_date):
    """
    Check if the age is over 16 years.

    Parameters:
        date_of_birth (str): Date of birth in the format "YYYY-MM-DD".
        delivery_date (str): Date of visit in the format "YYYY-MM-DD".

    Returns:
        bool: True if age is over 16 years, False otherwise.
    
    Example:
        over_16_check("2009-09-08", "2025-05-08") -> False
    """

    birth_datetime = datetime.strptime(date_of_birth, "%Y-%m-%d")
    delivery_datetime = datetime.strptime(delivery_date, "%Y-%m-%d")

    age = delivery_datetime.year - birth_datetime.year

    # Adjust if birthday hasn't occurred yet in the DOV month
    if (delivery_datetime.month < birth_datetime.month) or \
       (delivery_datetime.month == birth_datetime.month and delivery_datetime.day < birth_datetime.day):
        age -= 1

    return age >= 16

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