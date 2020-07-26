# roblox-web-datastore
Web-based datastore for Roblox for storing and fetching JSON strings

## Important Notice
This datastore was made when I was relatively new to backend development, based off gsck's efforts.
**You should not be storing JSON data as JSON strings** (although it is done here) in SQL or any other relational database.
MongoDB is better at dealing with this type of data, even better if a proper API is implemented.

## Requirements
### Server
- Node.JS
- MySQL/MariaDB
### Roblox
- Roblox Lua

## Suggested Alternative
### Server
Set up a proper API with Express and add security features such as API keys, replace MySQL with MongoDB
### Roblox
Use Lua Promises (such as [rbx-lua-promise](https://github.com/evaera/roblox-lua-promise)) for better handling of API requests
