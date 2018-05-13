module StockLocations.ListItem exposing (Model, view)

import Html exposing (Html, td, text, th, tr)
import Html.Attributes exposing (class, scope)


type alias Model =
    { sno: Int, id: Int, name : String, active : Bool }


view : Model -> Html a
view model =
    tr [ class "StockLocations__List__Item" ]
        [ th [ scope "col" ] [ text (toString model.sno) ]
        , td [] [ text model.name ]
        , td [] [ text (toString model.active) ]
        ]
