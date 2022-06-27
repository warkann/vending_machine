# frozen_string_literal: true

require_relative './vending_machine_validator'

class VendingMachine
  include VendingMachineValidator

  attr_reader :products

  def initialize(products:)
    @products = products
  end

  def buy(purchase:)
    products_clone = Marshal.load(Marshal.dump(products))
    result = []

    validate_item_code(product_codes: products.keys, item_code: purchase[:item_code])
    validate_money_amount(product_price: products[purchase[:item_code]][:price], money_amount: purchase[:money_amount])

    product = products[purchase[:item_code]]
    product[:item_code] = product.merge!(amount: product[:amount] -= 1)

    result << charge(purchase[:money_amount] - product[:price]) if purchase[:money_amount] > product[:price]
    result << "You have bought #{product[:name]} at the cost of #{product[:price]}."

    result.join(' ')
  rescue => ex
    result << 'Something went wrong.'

    @products = products_clone
    result << cancel(purchase: purchase)

    result.join(' ')

    raise ex
  end

  # in the real code Product will have a method to format string according to data structure
  def products_list
    puts products
  end

  def restock(income_products)
    @products = income_products
  end

  def stock(income_products)
    income_products.each_pair do |item_code, item_description|
      products[item_code] = if products[item_code].nil?
        item_description
      else
        products[item_code].merge!(amount: products[item_code][:amount] + item_description[:amount])
      end
    end
  end

  def cancel(purchase:)
    "Money returned: #{purchase[:money_amount]}."
  end

  private

  def charge(charge_amount)
    "Your charge is: #{charge_amount}."
  end
end
