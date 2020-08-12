terraform {
  required_version = "0.12.8"
}

provider "aws" {
  region                  = "ap-northeast-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "itsuki"
}

# for getting my public IP
provider "http" {
  version = "~> 1.1"
}
data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}