require 'rails_helper'

RSpec.describe CasesController, type: :controller do
  let(:cases) { FactoryGirl.create_list(:case, 20) }
  let(:state) {FactoryGirl.create(:state)}


  describe '#index' do

    before(:each) { get :index }

    it 'assigns the first 12 cases to @cases' do
      expect(assigns(:cases)).to match_array cases[0..11]
    end

    it 'success' do
      expect(response).to be_success
    end
  end

  describe '#show' do
    context 'when requested case exists' do
      let(:this_case) { cases.first }
      before(:each) { get :show, id: this_case.id }

      it 'success' do
        expect(response).to be_success
      end

      it 'assigns it to @case' do
        expect(assigns(:case)).to eq this_case
      end
    end

    context 'when requested case does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { get :show, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end

  describe '#create' do
    login_user

    context 'when valid' do
      let(:case_attrs) { FactoryGirl.attributes_for(:case) }
      let(:subject_attrs) { FactoryGirl.attributes_for(:subject) }

      it 'success' do
        case_attrs['subjects_attributes'] = {"0" => subject_attrs}
        post :create, {'case': case_attrs }
        expect(response).to redirect_to(case_path(Case.last))
      end

      it 'saves and assigns new case to @case' do
        case_attrs['subjects_attributes'] = {"0" => subject_attrs}
        post :create, {'case': case_attrs }
        expect(assigns(:case)).to be_a_kind_of(Case)
        expect(assigns(:case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:case_attrs) { attributes_for(:invalid_case) }

      it 'fails' do
        post :create, {'case': case_attrs}
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#update' do
    login_user
    let(:this_case) { create(:case) }

    context 'when valid' do
      let(:new_values) { { :overview => "new overview", :city => "Buffalo", :summary => "A summary of changes"} }

      it 'success' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(response).to redirect_to(case_path(Case.last))
      end

      it 'saves and assigns case to @case' do
        patch :update, ** new_values, id: this_case.id, case: new_values
        expect(assigns(:case)).to be_a_kind_of(Case)
        expect(assigns(:case)).to be_persisted
      end
    end

    context 'when invalid' do
      let(:new_values) { attributes_for(:invalid_case) }

      it 'redirects to the edit page' do
        patch :update, id: this_case.id, case: new_values
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    login_user
    context 'when requested case exists' do
      let(:this_case) { cases[rand 4] }
      before(:each) { delete :destroy, id: this_case.id }

      it 'success' do
        expect(response).to redirect_to(root_path)
      end

      it 'removes case form DB' do
        expect(Case.all).not_to include this_case
        expect { this_case.reload }.to raise_exception ActiveRecord::RecordNotFound
      end
    end

    context 'when requested case does not exists' do
      it 'throws ActiveRecord::RecordNotFound' do
        expect { delete :destroy, id: -1 }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end
end
