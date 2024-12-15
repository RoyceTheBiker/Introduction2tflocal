resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Music"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "TrackId"
  range_key      = "SongTitle"

  attribute {
    name = "TrackId"
    type = "S"
  }

  # attribute {
  #   name = "Artist"
  #   type = "S"
  # }

  # attribute {
  #   name = "SongTitle"
  #   type = "S"
  # }

  # attribute {
  #   name = "AlbumTitle"
  #   type = "S"
  # }

  # attribute {
  #   name = "Awards"
  #   type = "N"
  # }
}