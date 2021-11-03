class SerializableMessage < JSONAPI::Serializable::Resource
  type 'message'
  id { @object.id }

  attributes :content, :media

  attribute :name do
    @object.name || @object.user.name
  end
end
