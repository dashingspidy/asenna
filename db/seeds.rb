# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing records to prevent duplication in development
Brand.destroy_all
Supplier.destroy_all
Product.destroy_all
Inventory.destroy_all
Sale.destroy_all
SaleItem.destroy_all
StockTransaction.destroy_all
SupplierTransaction.destroy_all
User.destroy_all

# Create Brands
brands = [ "Pfizer", "Moderna", "Johnson & Johnson", "AstraZeneca" ].map { |name| Brand.create!(name: name) }

# Create Suppliers
suppliers = [
  { name: "MediSupply Co.", email: "medisupply@example.com", phone: 1234567890, brand: brands[0] },
  { name: "Pharma Distributors", email: "pharmadist@example.com", phone: 9876543210, brand: brands[1] }
].map { |attrs| Supplier.create!(attrs) }

# Create Products (Medicines)
products = [
  { name: "Paracetamol", description: "Pain reliever and fever reducer", price: 5.99, brand: brands[0] },
  { name: "Ibuprofen", description: "Nonsteroidal anti-inflammatory drug (NSAID)", price: 7.99, brand: brands[1] },
  { name: "Amoxicillin", description: "Antibiotic used to treat infections", price: 12.99, brand: brands[2] },
  { name: "Metformin", description: "Used for diabetes management", price: 9.99, brand: brands[3] },
  { name: "Atorvastatin", description: "Cholesterol-lowering medication", price: 15.49, brand: brands[0] },
  { name: "Omeprazole", description: "Reduces stomach acid, treats acid reflux", price: 8.99, brand: brands[1] },
  { name: "Losartan", description: "Treats high blood pressure", price: 10.99, brand: brands[2] },
  { name: "Levothyroxine", description: "Used for thyroid hormone replacement", price: 6.99, brand: brands[3] }
].map { |attrs| Product.create!(attrs) }

# Create Inventory Records
inventories = products.map { |product| Inventory.create!(product: product, quantity: 100, location: "Main Pharmacy") }

# Create Sales
sales = [ Sale.create!(total_price: 45.99, payment_method: "cash"), Sale.create!(total_price: 30.99, payment_method: "online") ]

# Create Sale Items
SaleItem.create!(sale: sales[0], product: products[0], quantity: 2, price: 11.98)
SaleItem.create!(sale: sales[0], product: products[2], quantity: 1, price: 12.99)
SaleItem.create!(sale: sales[1], product: products[5], quantity: 2, price: 17.98)

# Create Stock Transactions
StockTransaction.create!(inventory: inventories[0], transaction_type: "purchase", quantity: 100)
StockTransaction.create!(inventory: inventories[1], transaction_type: "purchase", quantity: 100)

# Create Supplier Transactions
SupplierTransaction.create!(supplier: suppliers[0], transaction_type: "payment", amount: 500.00, date: Date.today - 5)
SupplierTransaction.create!(supplier: suppliers[1], transaction_type: "purchase", amount: 1000.00, date: Date.today - 3)

# Create Users
User.create!(email_address: "admin@admin.com", password_digest: BCrypt::Password.create("123456"))

puts "Medicine-based seed data successfully loaded!"
