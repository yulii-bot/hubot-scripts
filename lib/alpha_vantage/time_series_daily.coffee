moment = require('moment-timezone')

class AlphaVantageTimeSeriesDaily
  _meta        = undefined
  _data        = undefined
  _timezone    = undefined
  _ts_keys     = undefined

  constructor: (object) ->
    _meta  = object['Meta Data']
    _data  = object['Time Series (Daily)']

    _initialize.call @

  outline: ->
    limit = _ts_keys.length - 1
    keys  = [1, 20, 60, 180].filter((x) -> x < limit).map((x) -> _ts_keys[x])

    compare = []
    for t in keys
      compare.push(
        timestamp: t,
        diff: @diffClosingPrice(t, @latestDate()),
        ratio: @ratioClosingPrice(t, @latestDate())
      )

    return
      timestamp: @latestDate()
      price: @closingPrice(@latestDate())
      compare: compare

  timezone: ->
    return _timezone

  latestDate: ->
    return _ts_keys[0]

  closingPrice: (timestamp) ->
    return parseFloat(_data[_key(timestamp)]['4. close'])

  diffClosingPrice: (begin, end) ->
    return _round(@closingPrice(end) - @closingPrice(begin), 5)

  ratioClosingPrice: (begin, end) ->
    return _round(100 * (@closingPrice(end) - @closingPrice(begin)) / @closingPrice(begin), 2)

  _initialize = ->
    _timezone    = _meta['5. Time Zone']
    _ts_keys     = Object.keys(_data).map((x) -> moment.tz(x, _timezone).valueOf()).sort((a, b) -> return (a < b ? 1 : -1))

  _key = (timestamp) ->
    return moment(timestamp).tz(_timezone).format('YYYY-MM-DD')

  _round = (value, digits) ->
    n = Math.pow(10, digits)
    return Math.round(value * n) / n

module.exports = AlphaVantageTimeSeriesDaily
