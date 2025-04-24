import pandas as pd 
from sqlalchemy import create_engine



try:
    csv_ds = pd.read_csv("cwurData.csv")
    xlsx_ds = pd.read_csv("IPEDS_data.csv")

    csv_ds['name'] = csv_ds['name'].str.strip()
    xlsx_ds['name'] = xlsx_ds['name'].str.strip()

    merged_ds = pd.merge(xlsx_ds, csv_ds, on="name", how="left")

    #connect through 'engine' 
    engine = create_engine("postgresql://thai_tran:Grayravens.1265@ada.mines.edu:5432/csci403")

    merged_ds.to_sql("University_Merged", con=engine, schema="group44", if_exists="replace", index=False)

    print("Success Import")

except Exception as e:
    print("Failure: ", e)