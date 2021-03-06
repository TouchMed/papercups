defmodule ChatApi.Accounts.Settings do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:disable_automated_reply_emails, :boolean)
  end

  @spec changeset(any(), map()) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    schema
    |> cast(params, [:disable_automated_reply_emails])
  end
end
