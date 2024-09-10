require 'rails_helper'

RSpec.describe "Employees API", type: :request do
  let(:valid_attributes) do
    {
      employee: {
        employee_id: 'EMP001',
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        phone_numbers: ['1234567890', '0987654321'],
        doj: '2023-05-16',
        salary: 50000
      }
    }
  end

  let(:invalid_attributes) do
    {
      employee: {
        employee_id: '',
        first_name: '',
        last_name: '',
        email: 'invalid-email',
        phone_numbers: [],
        doj: '',
        salary: -1000
      }
    }
  end

  describe "POST /employees" do
    context "with valid parameters" do
      it "creates a new Employee" do
        expect {
          post '/employees', params: valid_attributes
        }.to change(Employee, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Employee created successfully')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Employee" do
        expect {
          post '/employees', params: invalid_attributes
        }.to change(Employee, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Employee can't be blank", "Email is invalid")
      end
    end
  end

  describe "GET /employees/tax_deduction" do
    before do
      Employee.create!(
        employee_id: 'EMP001',
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        phone_numbers: ['1234567890', '0987654321'],
        doj: '2023-05-16',
        salary: 50000
      )
    end
    
    it "returns the tax deduction for the employee" do
      get '/employees/tax_deduction', params: { employee_id: 'EMP001' }
    
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['employee_code']).to eq('EMP001')
      expect(json_response['first_name']).to eq('John')
      expect(json_response['last_name']).to eq('Doe')
      expect(json_response['yearly_salary']).to be_within(0.01).of(525000.00)
      expect(json_response['tax_amount']).to be_within(0.01).of(15000.00)
      expect(json_response['cess_amount']).to eq(0)
    end    

    it "returns an error if the employee is not found" do
      get '/employees/tax_deduction', params: { employee_id: 'NONEXISTENT' }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Employee not found')
    end
  end
end
