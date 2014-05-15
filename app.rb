require 'sinatra'
require 'stripe'
require 'yaml'

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

PRODUCTS = YAML.load_file("./products.yml")

get '/' do
  @products = PRODUCTS
  erb :index
end

post '/charge/:product' do
  @product = PRODUCTS[params[:product]] or raise "Nope!"

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @product.amount,
    :description => 'CoworkBuffalo Shop',
    :currency    => 'usd',
    :customer    => customer.id,
    :metadata    => {
      :shipping_name    => params[:stripeShippingName],
      :shipping_address => params[:stripeShippingAddressLine1],
      :shipping_zip     => params[:stripeShippingAddressZip],
      :shipping_state   => params[:stripeShippingAddressState],
      :shipping_city    => params[:stripeShippingAddressCity],
      :shipping_country => params[:stripeShippingAddressCountry]
    }
  )

  erb :charge
end

error Stripe::CardError do
  env['sinatra.error'].message
end
