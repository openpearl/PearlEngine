PearlEngine::Engine.routes.draw do
  post 'converse'    => 'conversations#converse'
  get 'context'      => 'conversations#getContext'
  post 'context'     => 'conversations#setContext'

end
