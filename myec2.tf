
resource "aws_instance" "my-tfec2" {
  ami           = "ami-0d2692b6acea72ee6"
  instance_type = "t2.micro"
  }
resource "aws_eip" "lb" {
    instance = "${aws_instance.my-tfec2.id}"
     vpc      = true
  }
