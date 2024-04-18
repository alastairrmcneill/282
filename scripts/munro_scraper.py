import pandas as pd
import requests
from bs4 import BeautifulSoup


def writeStartingPointLinks():
    # Open munros.csv
    df = pd.read_csv('assets/munros.csv')

    # Loop through each line in the file
    for index, row in df.iterrows():
        walkHighlandsLink = row['link']
        
        startingPointLink = getStartPointLink(walkHighlandsLink)


        # Add the starting point link to the dataframe
        df.at[index, 'starting_point_link'] = startingPointLink    

        if startingPointLink == '':
            print(walkHighlandsLink)    

    # Overwrite munros.csv
    df.to_csv('assets/munros.csv', index=False)


def getStartPointLink(link):
    headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
    }
    # Get the HTML of the page
    response = requests.get(link, headers=headers)

    # Parse the HTML
    soup = BeautifulSoup(response.text, 'html.parser')


    # Find starting point link
    start_point = soup.find('a', string='Open start point in Google Maps for directions')
    print(f"start_point: {start_point}")

    if start_point:
        startingPointLink = start_point['href']
    else:

        # Find the h2 tag with the specific text
        h2_tag = soup.find('h2', string='Detailed route description and map')

        # Find the next a tag
        a_tag = h2_tag.find_next('a')

        print(f"a_tag: {a_tag}")

        newLink = "https://www.walkhighlands.co.uk"+(a_tag['href'])

        print(f"newLink: {newLink}" )

        # Get the HTML of the page
        newResponse = requests.get(newLink, verify=False, headers=headers)
        

        # Parse the HTML
        newSoup = BeautifulSoup(newResponse.text, 'html.parser')
        print(f"status code: {newResponse.status_code}")
        new_start_point = newSoup.find('a', string='Open start point in Google Maps for directions')

        print(f"second start_point: {new_start_point}")

        if new_start_point:
            startingPointLink = new_start_point['href']
        else: 
            startingPointLink = ''
    
    return startingPointLink



getStartPointLink("https://www.walkhighlands.co.uk/munros/carn-aosda")

