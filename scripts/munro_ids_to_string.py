import json

# Load the JSON file
with open('assets/munros.json', 'r') as f:
    data = json.load(f)

# Loop through the data and convert the "id" fields to strings
for munro in data:
    munro['id'] = str(munro['id'])

# Save the modified data back to the JSON file
with open('assets/munros.json', 'w') as f:
    json.dump(data, f, indent=4)