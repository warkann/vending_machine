# frozen_string_literal: true

require_relative './vending_machine_errors.rb'

module VendingMachineValidator
  private

  def validate_item_code(product_codes:, item_code:)
    raise VendingMachineErrors::InvalidItemCode unless product_codes.include?(item_code)
  end

  def validate_money_amount(product_price:, money_amount:)
    raise VendingMachineErrors::InvalidMoneyAmount if product_price > money_amount
  end
end
