resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Music"
  # billing_mode   = "PROVISIONED"
  # read_capacity  = 20
  # write_capacity = 20
  # hash_key       = "UserId"
  # range_key      = "GameTitle"

  attribute {
    name = "Artist"
    type = "S"
  }

  attribute {
    name = "SongTitle"
    type = "S"
  }

  attribute {
    name = "AlbumTitle"
    type = "S"
  }

  attribute {
    name = "Awards"
    type = "S"
  }
}