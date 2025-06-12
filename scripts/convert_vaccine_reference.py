import pandas as pd 
import json

df = pd.DataFrame(pd.read_excel("../input/vaccine_reference.xlsx"))

out_dict = {}
for index, row in df.iterrows():
    vaccine = row['Vaccine']
    diseases = []
    for disease in df.columns:
        if disease != 'Vaccine' and row[disease] == 1:
            diseases.append(disease)
    out_dict[vaccine] = diseases

with open("../input/vaccine_reference.json", "w", encoding="utf-8") as f:
    json.dump(out_dict, f, ensure_ascii=False, indent=4)