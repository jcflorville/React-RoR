class Api::V1::ContactsController < ApplicationController
  def index
    contacts = if params[:search].blank?
      Contact.all
    else
      Contact.where('first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    render json: serialization(contacts), status: :ok
  end

  def create
    contact = Contact.new(contact_params)

    if contact.save
      render json: serialization(contact), status: :ok
    else
      render json: { errors: contact.errors }, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email)
  end

  def serialization(data)
     { data: data.as_json(only: [ :id, :first_name, :last_name, :email ]) }
  end
end
