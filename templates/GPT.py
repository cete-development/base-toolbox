import requests

# Define the API endpoint URL
url = 'https://dummyjson.com/todos'

# Make a GET request to the API
response = requests.get(url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the JSON response
    data = response.json()
    # Do something with the data
    print(data)
else:
    # Print an error message if the request was unsuccessful
    print("Failed to retrieve data. Status code:", response.status_code)
