class SerializableCard < JSONAPI::Serializable::Resource
  type 'card'
  id { @object.id }

  attributes :title, :recipient_name, :group_name
end