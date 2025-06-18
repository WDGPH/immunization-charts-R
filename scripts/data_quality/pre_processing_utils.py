import pandas as pd
import sys
import logging

# Configure logging
logging.basicConfig(
    filename='column_cleaning.log',
    level=logging.INFO,
    format='%(asctime)s %(levelname)s:%(message)s'
)

# Remove all special characters from column names
def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    """
    Cleans the column names of a DataFrame by removing all special characters.
    Logs the original column names to a file.

    Args:
        df (pd.DataFrame): The DataFrame whose column names are to be cleaned.
    Returns:
        pd.DataFrame: The DataFrame with cleaned column names.
    """
    logging.info(f"Original column names: {list(df.columns)}")
    df.columns = df.columns.str.replace(r'[^a-zA-Z0-9_]', '', regex=True)
    return df

# Remove all special characters from each row

# Deduplication of client records (check for uniqueness of each client)

# Non-nullness

# Check to make sure that the age that is calculated is valid (no negative ages)

