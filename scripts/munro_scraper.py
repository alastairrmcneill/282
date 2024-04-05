import pandas as pd
import requests


def addLinks():
    # Open munros.csv
    df = pd.read_csv('assets/munros.csv')

    # Loop through each line in the file
    for index, row in df.iterrows():
        # Build weather link
        name = row['name'].replace(' ', '-')
        name = name.replace("'", '')
        weather_link = "https://www.mountain-forecast.com/peaks/" + name + "/forecasts/" + str(row['meters'])

        # Add weather link column
        df.loc[index, 'weather_link'] = weather_link

    # Overwrite munros.csv
    df.to_csv('assets/munros.csv', index=False)

def checkLinks():
    # Open munros.csv
    df = pd.read_csv('assets/munros.csv')

    # Loop through each line in the file
    for index, row in df.iterrows():
        # Check if the link is valid
        response = requests.get(row['weather_link'])
        if response.status_code != 200:
            print(row['name'] + " link is invalid")

# addLinks()
checkLinks()