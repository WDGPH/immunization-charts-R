import typst
from datetime import date, datetime

def calculate_age(DOB, DOV):

    DOB_datetime = datetime.strptime(DOB, "%Y-%m-%d")
    DOV_datetime = datetime.strptime(DOV, "%b %d, %Y")

    years = DOV_datetime.year - DOB_datetime.year
    months = DOV_datetime.month - DOB_datetime.month

    if DOV_datetime.day < DOB_datetime.day:
        months += 1
    
    if months < 0:
        years -= 1 
        months += 12 

    return(f"{years}Y {months}M")


def compile_typst(immunization_record, outpath):

    typst.compile(immunization_record, output = outpath)


# template_path = sys.argv[1]
# compile_typst(template_path, "../output/test.pdf")