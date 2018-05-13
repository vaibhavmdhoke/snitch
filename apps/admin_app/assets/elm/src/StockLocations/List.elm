module StockLocations.List exposing (..)

import StockLocations.ListItem as SLItem
import Html exposing (Html, button, div, h2, h3, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, colspan, scope)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, at, bool, field, int, list, map4, string)
import RemoteData exposing (WebData)

type alias Model =
    { stockLocations : WebData (List SLItem.Model)}


init : ( Model, Cmd Msg )
init =
    ( { stockLocations = RemoteData.NotAsked }, Cmd.none )


type Msg
    = SendHttpRequest
    | DataReceived (WebData (List SLItem.Model))



-- sendRequest :                            Request a -> Cmd (WebData a)
-- send        : (Result Error a -> msg) -> Request a -> Cmd msg


httpCommand : Cmd Msg
httpCommand =
    list stockLocationsDecoder
        |> at [ "data" ]
        |> Http.get "stock_locations/list"
        |> RemoteData.sendRequest
        |> Cmd.map DataReceived


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SendHttpRequest ->
            ( { model | stockLocations = RemoteData.Loading }, httpCommand )

        DataReceived response ->
            ( { model | stockLocations = response }, Cmd.none )


viewStockLocationsOrError : Model -> Html Msg
viewStockLocationsOrError model =
    case model.stockLocations of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            tr []
                [ td [ colspan 3, class "text-center" ]
                    [ h3 [ ] [ text "Loading..." ]
                    ]
                ]

        RemoteData.Success stocklocations ->
            tbody [] (renderStockLocations stocklocations)

        RemoteData.Failure httpError ->
            viewError (createErrorMessage httpError)


viewError : String -> Html Msg
viewError errorMessage =
    let
        errorHeading =
            "Couldn't fetch data at this time."
    in
    tr []
        [ td [ colspan 3, class "text-center" ]
            [ h3 [ ] [ text errorHeading ]
            , text ("Error: " ++ errorMessage)
            ]
        ]


createErrorMessage : Http.Error -> String
createErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "It appears you don't have an Internet connection right now."

        Http.BadStatus response ->
            response.status.message

        Http.BadPayload message response ->
            message


initialModel : Model
initialModel =
    { stockLocations = RemoteData.NotAsked }


stockLocationsDecoder : Decoder SLItem.Model
stockLocationsDecoder =
    map4 SLItem.Model
        (field "id" int)
        (field "id" int)
        (field "name" string)
        (field "active" bool)


renderStockLocation : SLItem.Model -> Html a
renderStockLocation stockLocation =
    SLItem.view stockLocation


renderStockLocations : List SLItem.Model -> List (Html a)
renderStockLocations stockLocations =
    List.indexedMap (\i x -> renderStockLocation { x | sno = i + 1 }) stockLocations


view : Model -> Html Msg
view model =
    div [ class "StockLocations--container" ]
        [ h2 [] [ text "Stock Location List" ]
        , button [ onClick SendHttpRequest, class "btn btn-primary" ] [ text "Fetch Stock Locations" ]
        , table [ class "StockLocations__List table" ]
            [ thead [ class "thead-dark" ]
                [ tr []
                    [ th [ scope "col" ] [ text "#" ]
                    , th [ scope "col" ] [ text "Name" ]
                    , th [ scope "col" ] [ text "Status" ]
                    ]
                ]
            , viewStockLocationsOrError model
            ]
        ]
