require 'test_helper'

class TwoCheckoutHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = TwoCheckout::Helper.new('order-500','cody@example.com', :amount => '5.00', :currency => 'USD')
  end

  def teardown
    ActiveMerchant::Billing::Base.integration_mode = :test
  end

  def test_basic_helper_fields
    assert_field 'sid', 'cody@example.com'
    assert_field 'total', '5.00'
    assert_field 'merchant_order_id', 'order-500'
  end

  def test_extra_helper_fields
    @helper.currency 'ZAR'
    @helper.invoice '123'
    @helper.return_url 'https://return.url/'
    @helper.notify_url 'https://notify.url/'
    @helper.cart_type 'shopify'
    @helper.purchase_step 'payment-method'

    assert_field 'currency_code', 'ZAR'
    assert_field 'cart_order_id', '123'
    assert_field 'notify_url', 'https://notify.url/'
    assert_field 'x_receipt_link_url', 'https://return.url/'
    assert_field '2co_cart_type', 'shopify'
    assert_field 'purchase_step', 'payment-method'
  end

  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com', :phone => '(555)555-5555'
    assert_field 'card_holder_name', 'Cody Fauser'
    assert_field 'email', 'cody@example.com'
    assert_field 'phone', '(555)555-5555'
  end

  def test_third_party_cart_fields
    @helper.third_party_cart :prod => "1,1", :name => 'Example Product Name'
    @helper.third_party_cart :description => 'Example Product Description', :price => '15.0'

    assert_field 'c_prod_1', '1,1'
    assert_field 'c_name_1', 'Example Product Name'

    assert_field 'c_description_2', 'Example Product Description'
    assert_field 'c_price_2', '15.0'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'Apt. 1',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_field 'street_address', '1 My Street'
    assert_field 'street_address2', 'Apt. 1'
    assert_field 'city', 'Leeds'
    assert_field 'state', 'Yorkshire'
    assert_field 'zip', 'LS2 7EE'
    assert_field 'country', 'CA'
  end

  def test_shipping_address
    @helper.shipping_address :name => 'Testing Tester',
                             :address1 => '1 My Street',
                             :address2 => 'Apt. 1',
                             :city => 'London',
                             :state => 'Whales',
                             :zip => 'LS2 7E1',
                             :country  => 'GB'

    assert_field 'ship_name', 'Testing Tester'
    assert_field 'ship_city', 'London'
    assert_field 'ship_street_address', '1 My Street'
    assert_field 'ship_state', 'Whales'
    assert_field 'ship_zip', 'LS2 7E1'
    assert_field 'ship_country', 'GB'
  end

  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 5, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end

  def test_test_mode
    @helper = TwoCheckout::Helper.new('order-500','cody@example.com', :amount => '5.00', :currency => 'USD')
    assert_field 'demo', 'Y'
  end

  def test_force_test_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    @helper = TwoCheckout::Helper.new('order-500','cody@example.com', :amount => '5.00', :currency => 'USD', :test => true)
    assert_field 'demo', 'Y'
  end

  def test_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    @helper = TwoCheckout::Helper.new('order-500','cody@example.com', :amount => '5.00', :currency => 'USD')
    assert !@helper.fields.has_key?("demo")
  end
end
