import pandas as pd
import re

def parse_custom_date(date_str, fallback_str=None):
    """
    Parse a custom date string into a proper datetime object.
    
    Handles formats such as:
      - "81 Jul 24-27" → uses the first day ("24")
      - "81 Jul 31-Aug 3" → extracts the day from "31-Aug" (i.e. "31")
      
    If fallback_str (e.g., "Jul 1981") is provided, it is used to determine the full year.
    If fallback_str is None, an attempt is made to parse date_str directly.
    """
    # If no fallback is provided, try a direct parse
    if fallback_str is None:
        try:
            return pd.to_datetime(date_str, errors='coerce')
        except Exception as e:
            print("Error parsing date:", date_str, e)
            return pd.NaT

    def extract_day(s):
        m = re.match(r"(\d+)", s)
        if m:
            return m.group(1)
        return None

    try:
        parts = date_str.split()
        if len(parts) == 3:
            # Format: "81 Jul 24-27"
            year_str, month_str, day_range = parts
            day = day_range.split('-')[0]
        elif len(parts) == 4:
            # Format: "81 Jul 31-Aug 3"
            year_str, month_str, day_range_with_month, _ = parts
            day = extract_day(day_range_with_month)
        else:
            return pd.NaT
        
        # Use fallback_str (e.g., "Jul 1981") to extract the full year.
        fallback_date = pd.to_datetime(fallback_str, format="%b %Y", errors='coerce')
        if pd.notna(fallback_date):
            year = fallback_date.year
        else:
            # If fallback fails, use a heuristic on the two-digit year.
            year = int(year_str)
            if year < 50:
                year += 2000
            else:
                year += 1900
        
        new_date_str = f"{year} {month_str} {day}"
        return pd.to_datetime(new_date_str, format="%Y %b %d")
    except Exception as e:
        print("Error parsing custom date:", date_str, "with fallback:", fallback_str, e)
        return pd.NaT

# Process files data-1.csv through data-15.csv
files = [f"data-{i}.csv" for i in range(1, 16)]
dfs = []

for file in files:
    try:
        df = pd.read_csv(file)
    except Exception as e:
        print(f"Error reading file {file}: {e}")
        continue

    # Standardize the 'President' column if it exists, else assign a default.
    if 'President' in df.columns:
        df['President'] = df['President'].str.strip().str.title()
    else:
        df['President'] = f"Unknown_{file}"
    
    # Determine which column to use for Approval.
    # Check for "% Approve", then "% Approval", then "Approve".
    approval_col = None
    for candidate in ["% Approve", "% Approval", "Approve"]:
        if candidate in df.columns:
            approval_col = candidate
            break
    if approval_col:
        df["Approval"] = df[approval_col]
    else:
        df["Approval"] = None

    # Process the Date column.
    # If there's a fallback column ("X.1"), use it with our custom parser.
    if 'X.1' in df.columns:
        df["Parsed_Date"] = df.apply(lambda row: parse_custom_date(row["Date"], row["X.1"]), axis=1)
    else:
        # Otherwise, try to parse the Date directly.
        df["Parsed_Date"] = pd.to_datetime(df["Date"], errors='coerce')
    
    # Convert the parsed dates to string in YYYY-MM-DD format.
    df["Date"] = df["Parsed_Date"].dt.strftime("%Y-%m-%d")
    
    # Keep only the desired columns: President, Date, Approval.
    df = df[["President", "Date", "Approval"]]
    
    dfs.append(df)

# Combine all DataFrames into one final DataFrame.
combined_data = pd.concat(dfs, ignore_index=True)

# Remove rows where any of the desired columns are missing/empty.
combined_data.dropna(subset=["President", "Date", "Approval"], inplace=True)

# Optionally, sort the data by Date and President.
combined_data.sort_values(by=["Date", "President"], inplace=True)

# Preview the final DataFrame
print(combined_data.head(20))

# Save the standardized data to a new CSV file.
combined_data.to_csv("approval_ratings_clean.csv", index=False)
