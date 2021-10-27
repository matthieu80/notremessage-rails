class SerializableUser < JSONAPI::Serializable::Resource
  type 'user'
  id { @object.id }

  attributes :name, :email
  has_many :cards
end