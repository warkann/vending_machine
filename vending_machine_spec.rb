# frozen_string_literal: true

require_relative './vending_machine'

RSpec.describe VendingMachine do
  let(:item1) { {'001' => { amount: 5, price: 10, name: 'Water' }} }
  let(:item2) { {'002' => { amount: 7, price: 15, name: 'Coca-Cola' }} }
  let(:item3) { {'001' => { amount: 6, price: 10, name: 'Water' }} }

  let(:purchase1) { { money_amount: 10, item_code: '001' } }
  let(:purchase2) { { money_amount: 15, item_code: '002' } }
  let(:purchase3) { { money_amount: 15, item_code: '001' } }
  let(:purchase4) { { money_amount: 15, item_code: '0011' } }
  let(:purchase5) { { money_amount: 5, item_code: '001' } }

  context '#stock' do
    subject { described_class.new(products: item1) }

    it 'adds new item to the product list' do
      subject.stock(item2)

      expect(subject.products.keys).to include(item2.keys.first)
    end

    it 'increases existing item\'s amount' do
      prev_amount = subject.products[item1.keys.first][:amount]

      subject.stock(item3)

      expect(subject.products[item1.keys.first][:amount]).to eq(prev_amount + item3[item3.keys.first][:amount])
    end
  end

  context '#restock' do
    subject { described_class.new(products: item1) }

    it 'replaces all products in the machine' do
      subject.restock(item2)

      expect(subject.products.keys).not_to include(item1.keys.first)
    end
  end

  context '#buy' do
    subject { described_class.new(products: item1) }

    it 'allows to buy a product' do
      expect(subject.buy(purchase: purchase1)).to eq("You have bought #{item1[item1.keys.first][:name]} at the cost of #{item1[item1.keys.first][:price]}.")
    end

    it 'allows to get charge' do
      expect(subject.buy(purchase: purchase3)).to include("Your charge is: #{purchase3[:money_amount] - item1[item1.keys.first][:price]}.")
    end

    it 'decreases product count' do
      start_count = item1[item1.keys.first][:amount]
      subject.buy(purchase: purchase1)

      expect(subject.products[item1.keys.first][:amount]).to eq(start_count - 1)
    end

    it 'doesn\'t allow to buy invalid product' do
      expect { subject.buy(purchase: purchase4) }.to raise_error(VendingMachineErrors::InvalidItemCode)
    end

    it 'doesn\'t allow to buy product with invalid money amount' do
      expect { subject.buy(purchase: purchase5) }.to raise_error(VendingMachineErrors::InvalidMoneyAmount)
    end

    it 'doesn\'t change products count after error' do
      start_count = item1[item1.keys.first][:amount]
      expect(subject).to receive(:charge).and_raise(StandardError)

      expect { subject.buy(purchase: purchase3) }.to raise_error(StandardError)

      expect(subject.products[item1.keys.first][:amount]).to eq(start_count)
    end
  end

  context '#cancel' do
    subject { described_class.new(products: item1) }

    it 'allows to return money' do
      expect(subject.cancel(purchase: purchase1)).to eq("Money returned: #{purchase1[:money_amount]}.")
    end
  end
end
