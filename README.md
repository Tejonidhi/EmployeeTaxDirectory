# README
Ruby-3.0.2
Rails-7.1.4
-------------------------------------------------------------
Migration
rails db:migrate
-------------------------------------------------------------
Execute test case
bundle exec rspec
--------------------------------------------------------------
API End points
Note: I have used Postman for API End point testing
Employee Creation 
Method:POST
http://localhost:3000/employees
eg: {
  "employee": {
    "employee_id": "EMP004",
    "first_name": "cess1",
    "last_name": "test",
    "email": "cess_test1@example.com",
    "phone_numbers": ["1234567777", "8587654321"],
    "doj": "2023-05-16",
    "salary": "50000"
  }
}

Employee Tax calculation
Method: GET
eg: http://localhost:3000/employees/tax_deduction?employee_id=EMP004

---------------------------------------------------------
