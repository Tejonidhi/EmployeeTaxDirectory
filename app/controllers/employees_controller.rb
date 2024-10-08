class EmployeesController < ApplicationController
    # Endpoint to store employee details
    def create
      employee = Employee.new(employee_params)
      if employee.save
        render json: { message: 'Employee created successfully', employee: employee }, status: :created
      else
        render json: { errors: employee.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # Endpoint to return employee tax deduction
    def tax_deduction
      employee = Employee.find_by(employee_id: params[:employee_id])
      
      if employee.nil?
        render json: { error: 'Employee not found' }, status: :not_found
        return
      end
  
      yearly_salary = calculate_yearly_salary(employee)
      tax = calculate_tax(yearly_salary)
      cess = calculate_cess(yearly_salary)
  
      render json: {
        employee_code: employee.employee_id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        yearly_salary: yearly_salary.round(2),
        tax_amount: tax.round(2),
        cess_amount: cess.round(2)
      }, status: :ok
    end
  
    private
  
    def employee_params
      params.require(:employee).permit(:employee_id, :first_name, :last_name, :email, :doj, :salary, phone_numbers: [])
    end
  
    # Method to calculate yearly salary considering DOJ
    def calculate_yearly_salary(employee)
      doj = employee.doj
      salary_per_month = employee.salary.to_f
      financial_year_start = Date.new(Date.current.year - 1, 4, 1) # Financial year starts on April 1st
      financial_year_end = Date.new(Date.current.year, 3, 31) # Financial year ends on March 31st
    
      # Use the later of DOJ or the start of the financial year
      doj = [doj, financial_year_start].max 
    
      # If DOJ is after April, exclude April completely
      if doj > financial_year_start
        complete_months_worked = (financial_year_end.year * 12 + financial_year_end.month) - (doj.year * 12 + doj.month)
      else
        complete_months_worked = 11 # April to March excluding DOJ month
      end
    
      # Calculate partial month salary for the DOJ month if DOJ is not on the first day of the month
      partial_month_salary = 0
      if doj.day > 1
        days_worked_in_doj_month = 30 - doj.day + 1 # Days worked in the month of joining
        partial_month_salary = (salary_per_month / 30) * days_worked_in_doj_month
      end
    
      # Total salary is the sum of complete months' salary and partial month's salary
      complete_months_salary = complete_months_worked * salary_per_month
      total_salary = complete_months_salary + partial_month_salary
    
      total_salary
    end
      
      
  
    # Method to calculate tax based on slabs
    def calculate_tax(yearly_salary)
      tax = 0
      if yearly_salary > 250000
        if yearly_salary > 500000
          tax += 12500 # Tax for 250001 to 500000
          if yearly_salary > 1000000
            tax += 50000 # Tax for 500001 to 1000000
            tax += (yearly_salary - 1000000) * 0.2 # Tax for amount above 1000000
          else
            tax += (yearly_salary - 500000) * 0.1 # Tax for amount above 500000 and below or equal to 1000000
          end
        else
          tax += (yearly_salary - 250000) * 0.05 # Tax for amount above 250000 and below or equal to 500000
        end
      end
      tax
    end
  
    # Method to calculate cess
    def calculate_cess(yearly_salary)
      cess = 0
      if yearly_salary > 2500000
        cess = (yearly_salary - 2500000) * 0.02 # Cess for the amount over 2500000
      end
      cess
    end
  end
  