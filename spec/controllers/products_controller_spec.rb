require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  let!(:product) { create(:product) } # Assuming you have a factory for the Product model

  describe 'GET #index' do
    it 'returns a success response with all products' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
      expect(JSON.parse(response.body).size).to eq(1) # Assuming one product is created
    end
  end

  describe 'GET #show' do
    it 'returns a success response for a valid product' do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(product.id)
    end

    it 'returns a not found response for an invalid product' do
      get :show, params: { id: 9999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Product not found')
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_attributes) { { product: { name: 'New Product', price: 10.0 } } }

      it 'creates a new product' do
        expect {
          post :create, params: valid_attributes
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['name']).to eq('New Product')
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) { { product: { name: '', price: 5 } } }

      it 'does not create a new product' do
        post :create, params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid attributes' do
      it 'updates the product' do
        patch :update, params: { id: product.id, product: { name: 'Updated Product' } }
        expect(response).to have_http_status(:ok)
        product.reload
        expect(product.name).to eq('Updated Product')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the product' do
        patch :update, params: { id: product.id, product: { name: '', price: 5 } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the product' do
      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns a not found response for an invalid product' do
      delete :destroy, params: { id: 9999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Product not found')
    end
  end
end
