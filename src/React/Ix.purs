module React.Ix 
  ( class Subrow
  , get
  , getIx
  , set
  , setIx
  , insertIx
  , deleteIx

  , RenderIx
  , GetInitialStateIx
  , ComponentWillMountIx
  , ComponentDidMountIx
  , ComponentWillReceivePropsIx
  , ShouldComponentUpdateIx
  , ComponentWillUpdateIx
  , ComponentDidUpdateIx
  , ComponentWillUnmountIx

  , ReactThisIx(..)
  , ReactSpecIx

  , specIx
  , specIx'

  , toReactSpec
  , createClassIx

  , refFn
  ) where

import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Uncurried (EffFn2, EffFn3, runEffFn2, runEffFn3)
import DOM.HTML.Types (HTMLElement)
import Data.Symbol (reflectSymbol)
import Prelude (Unit, pure, unit, void, ($))
import React (Disallowed, ReactClass, ReactElement, ReactProps, ReactRefs, ReactSpec, ReactState, ReactThis, ReadOnly, ReadWrite, createClass)
import React.DOM.Props (Props, unsafeMkProps)
import React.Ix.EffR (EffR(..), unsafePerformEffR)
import Type.Data.Symbol (class IsSymbol, SProxy)
import Type.Row (class RowLacks)
import Unsafe.Coerce (unsafeCoerce)

newtype ReactThisIx p s (r :: # Type) = ReactThisIx (ReactThis p s)

class Subrow (r :: # Type) (s :: # Type)
instance srInst :: Union r t s => Subrow r s

foreign import unsafeGetImpl :: forall a b eff. EffFn2 eff String a b

get
  :: forall r r' l a p s eff
   . IsSymbol l
  => RowCons l a r' r
  => SProxy l
  -> ReactThisIx p s r
  -> Eff eff a
get l r = runEffFn2 unsafeGetImpl (reflectSymbol l) r

getIx
  :: forall r r' l a p s eff
   . IsSymbol l
  => RowCons l a r' r
  => SProxy l
  -> ReactThisIx p s r
  -> EffR eff { | r} { | r} a
getIx l r = EffR (get l r)

foreign import unsafeSetImpl :: forall a b c eff. EffFn3 eff String a b c

set
  :: forall r1 r2 r l a b p s eff
   . IsSymbol l
  => RowCons l a r r1
  => RowCons l b r r2
  => SProxy l
  -> b
  -> ReactThisIx p s r1
  -> Eff eff (ReactThisIx p s r2)
set l b r = runEffFn3 unsafeSetImpl (reflectSymbol l) b r

setIx
  :: forall r1 r2 r l a b p s eff
   . IsSymbol l
  => RowCons l a r r1
  => RowCons l b r r2
  => SProxy l
  -> b
  -> ReactThisIx p s r1
  -> EffR eff { | r} { | r} (ReactThisIx p s r2)
setIx l b r = EffR $ set l b r

foreign import unsafeInsertImpl :: forall a b c eff. EffFn3 eff String a b c

insertIx
  :: forall r1 r2 l a p s eff
   . IsSymbol l
  => RowLacks l r1
  => RowCons l a r1 r2
  => SProxy l
  -> a
  -> ReactThisIx p s r1
  -> EffR eff { | r1} { | r2} (ReactThisIx p s r2)
insertIx l a r = EffR $ runEffFn3 unsafeInsertImpl (reflectSymbol l) a r

foreign import unsafeDeleteImpl :: forall a b eff. EffFn2 eff String a b

deleteIx
  :: forall r1 r2 l a p s eff
   . IsSymbol l
  => RowLacks l r1
  => RowCons l a r1 r2
  => SProxy l
  -> ReactThisIx p s r2
  -> EffR eff { | r2} { | r1} (ReactThisIx p s r1)
deleteIx l r = EffR $ runEffFn2 unsafeDeleteImpl (reflectSymbol l) r

-- | A render function.
type RenderIx props state ri ro eff
   = ReactThisIx props state ri
   -> EffR
      ( props :: ReactProps
      , refs :: ReactRefs Disallowed
      , state :: ReactState ReadOnly
      | eff
      )
      { | ri} { | ro}
      ReactElement

-- | A get initial state function.
type GetInitialStateIx props state r eff
    = ReactThisIx props state r
    -> EffR
      ( props :: ReactProps
      , state :: ReactState Disallowed
      , refs :: ReactRefs Disallowed
      | eff
      )
      { | r} { | r}
      state

-- | A component will mount function.
type ComponentWillMountIx props state r eff
   = ReactThisIx props state ()
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadWrite
      , refs :: ReactRefs Disallowed
      | eff
      )
      {} { | r}
      (ReactThisIx props state r)

-- | A component did mount function.
type ComponentDidMountIx props state r eff
   = ReactThisIx props state r
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadWrite
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | r}
      Unit

-- | A component will receive props function.
type ComponentWillReceivePropsIx props state r eff
   = ReactThisIx props state r
   -> props
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadWrite
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | r}
      Unit

-- | A should component update function.
type ShouldComponentUpdateIx props state (r :: # Type) (eff :: # Effect)
   = ReactThisIx props state r
  -> props
  -> state
  -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadWrite
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | r}
      Boolean

-- | A component will update function.
type ComponentWillUpdateIx props state r eff
   = ReactThisIx props state r
   -> props
   -> state
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadWrite
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | r}
      Unit

-- | A component did update function.
type ComponentDidUpdateIx props state r eff
   = ReactThisIx props state r
   -> props
   -> state
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadOnly
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | r}
      Unit

-- | A component will unmount function.
type ComponentWillUnmountIx props state r ro eff
   = ReactThisIx props state r
   -> EffR
      ( props :: ReactProps
      , state :: ReactState ReadOnly
      , refs :: ReactRefs ReadOnly
      | eff
      )
      { | r} { | ro}
      (ReactThisIx props state ro)

type ReactSpecIx p s (r :: # Type) (rr :: # Type) (ro :: # Type) (eff :: # Effect) =
  Subrow r rr =>
  Subrow ro rr =>
  { render :: RenderIx p s r rr eff
  , displayName :: String
  , getInitialState :: GetInitialStateIx p s r eff
  , componentWillMount :: ComponentWillMountIx p s r eff
  , componentDidMount :: ComponentDidMountIx p s r eff
  , componentWillReceiveProps :: ComponentWillReceivePropsIx p s r eff
  , shouldComponentUpdate :: ShouldComponentUpdateIx p s r eff
  , componentWillUpdate :: ComponentWillUpdateIx p s r eff
  , componentDidUpdate :: ComponentDidUpdateIx p s r eff
  , componentWillUnmount :: ComponentWillUnmountIx p s rr ro eff
  }

specIx'
  :: forall p s r rr ro eff
   . Subrow ro rr
  => Subrow r rr
  => GetInitialStateIx p s r eff
  -> ComponentWillMountIx p s r eff
  -> ComponentWillUnmountIx p s rr ro eff
  -> RenderIx p s r rr eff
  -> ReactSpecIx p s r rr ro eff
specIx' getInitialState componentWillMount componentWillUnmount renderFn =
  { render: renderFn
  , displayName: ""
  , getInitialState: getInitialState
  , componentWillMount: componentWillMount
  , componentDidMount: \_ -> pure unit
  , componentWillReceiveProps: \_ _ -> pure unit
  , shouldComponentUpdate: \_ _ _ -> pure true
  , componentWillUpdate: \_ _ _ -> pure unit
  , componentDidUpdate: \_ _ _ -> pure unit
  , componentWillUnmount: componentWillUnmount
  }

specIx
  :: forall p s eff
   . s
  -> RenderIx p s () () eff
  -> ReactSpecIx p s () () () eff
specIx s r = (specIx' (\_ -> pure s) pure pure r)

toReactSpec
  :: forall p s r rr ro eff
   . Subrow r rr
  => Subrow ro rr
  => ReactSpecIx p s r rr ro eff
  -> ReactSpec p s eff
toReactSpec
  { render
  , displayName
  , getInitialState
  , componentWillMount
  , componentDidMount
  , componentWillReceiveProps
  , shouldComponentUpdate
  , componentWillUpdate
  , componentDidUpdate
  , componentWillUnmount
  }
  = { render: \this -> case render (ReactThisIx this) of EffR m -> m
    , displayName
    , getInitialState: \this -> case getInitialState (ReactThisIx this) of EffR m -> m
    , componentWillMount: \this -> case componentWillMount (ReactThisIx this) of EffR m -> void m
    , componentDidMount: \this -> case componentDidMount (ReactThisIx this) of EffR m -> m
    , componentWillReceiveProps: \this p -> case componentWillReceiveProps (ReactThisIx this) p of EffR m -> void m
    , shouldComponentUpdate: \this p s -> case shouldComponentUpdate (ReactThisIx this) p s of EffR m -> m
    , componentWillUpdate: \this p s -> case componentWillUpdate  (ReactThisIx this) p s of EffR m -> m
    , componentDidUpdate: \this p s -> case componentDidUpdate (ReactThisIx this) p s of EffR m -> m
    , componentWillUnmount: \this -> case componentWillUnmount (ReactThisIx this) of EffR m -> void m
    }

createClassIx
  :: forall p s r rr ro eff
   . Subrow r rr
  => Subrow ro rr
  => ReactSpecIx p s r rr ro eff
  -> ReactClass p
createClassIx spc = createClass (toReactSpec spc)

refFn
  :: forall eff ri ro
   . (HTMLElement -> EffR eff ri ro Unit)
  -> EffR eff ri ro Props
refFn fn = unsafeCoerce (unsafeMkProps "ref" (\e -> unsafePerformEffR (fn e)))
