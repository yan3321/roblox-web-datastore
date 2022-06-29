const http = require("http");
const mysql = require("mysql");

const hostname = "1.2.3.4";
const port = 5050;

const pool = mysql.createPool({
  connectionLimit: 25,
  host: "localhost",
  user: "username",
  password: "password",
  database: "datastore",
});

function IsJsonString(str) {
  try {
    JSON.parse(str);
  } catch (e) {
    return false;
  }
  return true;
}

const server = http.createServer((request, response) => {
  let urlBase = new URL(request.url, `http://${request.headers.host}`);
  console.log(urlBase);
  const key = urlBase.searchParams.get("key");
  if (key) {
    if (request.method == "POST") {
      console.log("POST request made");
      let body = "";
      request.on("data", function (data) {
        body += data;
        console.log("Partial body: " + body);
      });
      request.on("end", function () {
        console.log("Body: " + body);
        const bodyJson = JSON.parse(body);
        if (bodyJson) {
          const value = bodyJson;
          if (key && value) {
            pool.getConnection(function (err, connection) {
              if (err) {
                connection.release();
                response.writeHead(400, {
                  "Content-Type": "text/html",
                });
                response.end(err);
              }
              const valueJSON = JSON.stringify(value);
              connection.query(
                "REPLACE INTO `store` (`dataKey`, `value`) VALUES ('" +
                  key +
                  "', '" +
                  valueJSON +
                  "');",
                function (err, result) {
                  if (err) {
                    connection.release();
                    response.writeHead(400, {
                      "Content-Type": "text/html",
                    });
                    response.end(err);
                  } else {
                    connection.release();
                    response.writeHead(200, {
                      "Content-Type": "text/html",
                    });
                    response.end("successful post");
                  }
                }
              );
            });
          } else {
            response.writeHead(400, {
              "Content-Type": "text/html",
            });
            response.end("err");
          }
        }
      });
    } else if (request.method == "GET") {
      console.log("GET request made");
      if (key) {
        pool.getConnection(function (err, connection) {
          if (err) {
            connection.release();
            response.writeHead(400, {
              "Content-Type": "text/html",
            });
            response.end(err);
          }
          connection.query(
            "SELECT * FROM `store` WHERE `dataKey` = '" + key + "';",
            function (err, result, fields) {
              if (err) {
                connection.release();
                response.writeHead(400, {
                  "Content-Type": "text/html",
                });
                response.end(err);
              }
              const resultTable = result[0];
              if (resultTable) {
                if (resultTable.dataKey && resultTable.value) {
                  const rawValue = resultTable.value;
                  const resultJSON = IsJsonString(rawValue);
                  if (resultJSON) {
                    connection.release();
                    response.writeHead(200, {
                      "Content-Type": "application/json",
                    });
                    console.log("JSON response");
                    response.end(rawValue);
                  } else {
                    connection.release();
                    response.writeHead(200, {
                      "Content-Type": "application/json",
                    });
                    console.log("JSON response");
                    response.end(JSON.stringify(rawValue));
                  }
                } else {
                  connection.release();
                  response.writeHead(400, {
                    "Content-Type": "text/html",
                  });
                  console.log("Error response");
                  response.end(err);
                }
              } else {
                connection.release();
                response.writeHead(200, {
                  "Content-Type": "application/json",
                });
                console.log("JSON response");
                response.end(JSON.stringify({}));
              }
            }
          );
        });
      } else {
        response.writeHead(400, {
          "Content-Type": "text/html",
        });
        console.log("Error response");
        response.end("error");
      }
    }
  }
});

server.listen(port, hostname, () => {
  console.log("Database loaded on " + hostname + ":" + port);
});
