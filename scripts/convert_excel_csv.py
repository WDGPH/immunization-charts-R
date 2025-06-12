import pandas as pd 
import sys

path = sys.argv[1]
out_path = path[:-4] + 'csv'

df = pd.DataFrame(pd.read_excel(path, sheet_name='Sheet1')) 

df.to_csv(out_path, index = False, sep = ';')
