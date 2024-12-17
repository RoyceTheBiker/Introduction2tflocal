#!/bin/bash

eval $(grep ^PATH ~/.bashrc) # Load the PATH value

awslocal dynamodb put-item --table-name Music --item \
  '{"TrackId": {"S": "1"}, "Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Call Me Today"}, "AlbumTitle": {"S": "Somewhat Famous"}, "Awards": {"N": "1"}}'

awslocal dynamodb put-item --table-name Music --item \
  '{"TrackId": {"S": "2"}, "Artist": {"S": "No One You Know"}, "SongTitle": {"S": "Howdy"}, "AlbumTitle": {"S": "Somewhat Famous"}, "Awards": {"N": "2"}}'

awslocal dynamodb put-item --table-name Music --item \
  '{"TrackId": {"S": "3"}, "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "Happy Day"}, "AlbumTitle": {"S": "Songs About Life"}, "Awards": {"N": "10"}}'

awslocal dynamodb put-item --table-name Music --item \
  '{"TrackId": {"S": "4"}, "Artist": {"S": "Acme Band"}, "SongTitle": {"S": "PartiQL Rocks"}, "AlbumTitle": {"S": "Another Album Title"}, "Awards": {"N": "8"}}'

awslocal dynamodb scan --table-name Music | jq