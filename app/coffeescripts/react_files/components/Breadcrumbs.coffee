define [
  'i18n!react_files'
  'jquery'
  'underscore'
  'react'
  'react-router'
  'jsx/files/BreadcrumbCollapsedContainer'
  'compiled/react/shared/utils/withReactElement'
  '../modules/customPropTypes'
], (I18n, $, _, React, ReactRouter, BreadcrumbCollapsedContainerComponent, withReactElement, customPropTypes) ->

  MAX_CRUMB_WIDTH = 500
  MIN_CRUMB_WIDTH = if window.ENV.use_new_styles then 80 else 40

  Link =   ReactRouter.Link
  BreadcrumbCollapsedContainer =   BreadcrumbCollapsedContainerComponent

  Breadcrumbs =
    displayName: 'Breadcrumbs'

    propTypes:
      rootTillCurrentFolder: React.PropTypes.arrayOf(customPropTypes.folder)

    mixins: [ReactRouter.State]

    getInitialState: ->
      {
        maxCrumbWidth: MAX_CRUMB_WIDTH
        availableWidth: 200000
      }

    componentWillMount: ->
      # Get the existing Canvas breadcrumbs, store them, and remove them
      @fixOldCrumbs()

    componentDidMount: ->
      # Attach the resize listener to dynamically change the components
      # involved in the breadcrumb trail.
      $(window).on('resize', @handleResize)
      @handleResize()


    componentWillUnmount: ->
      $(window).off('resize', @handleResize)

    fixOldCrumbs: ->
      $oldCrumbs = $('#breadcrumbs')
      heightOfOneBreadcrumb = $oldCrumbs.find('li:visible:first').height() * 1.5
      homeName = $oldCrumbs.find('.home').text()
      $a = $oldCrumbs.find('li').eq(1).find('a')
      contextUrl = $a.attr('href')
      contextName = $a.text()
      if (ENV.use_new_styles)
        $('.ic-app-nav-toggle-and-crumbs').remove()
      else
        $oldCrumbs.remove()
      @setState({homeName, contextUrl, contextName, heightOfOneBreadcrumb})

    handleResize: ->
      @startRecalculating(window.innerWidth)

    startRecalculating: (newAvailableWidth) ->
      @setState({
        availableWidth: newAvailableWidth
        maxCrumbWidth: MAX_CRUMB_WIDTH
      }, @checkIfCrumbsFit)

    componentWillReceiveProps: -> setTimeout(@startRecalculating)

    checkIfCrumbsFit: ->
      return unless @state.heightOfOneBreadcrumb
      breadcrumbHeight = $(@refs.breadcrumbs.getDOMNode()).height()
      if (breadcrumbHeight > @state.heightOfOneBreadcrumb) and (@state.maxCrumbWidth > MIN_CRUMB_WIDTH)
        maxCrumbWidth = Math.max(MIN_CRUMB_WIDTH, @state.maxCrumbWidth - 20)
        @setState({maxCrumbWidth}, @checkIfCrumbsFit)
