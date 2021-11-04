class SerializableMessage < JSONAPI::Serializable::Resource
  type 'message'
  id { @object.id }

  attributes :card_id, :content, :media

  attribute :name do
    @object.name || @object.user.name
  end

  attribute :immediate_update_token do
    @object.immediate_update_token
  end

  attribute :immediate_update_token_expired_at do
    @object.immediate_update_token_expired_at.to_i
  end
end
