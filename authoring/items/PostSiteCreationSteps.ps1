Import-Function Get-ItemByIdSafe

function Get-ItemId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [String]$ItemPath
    )
    
    process {
        $item = Get-Item -Path $ItemPath
        $item.ID
    }   
}

function Update-PageTemplate {
    param(
        [Parameter(Mandatory = $true)]
        [String]$BaseTemplateId,
        [Parameter(Mandatory = $true)]
        [String]$TemplateName,
        [Parameter(Mandatory = $true)]
        [String]$TemplatesRootPath
        )
    
    process {
        $baseTemplate = Get-Item -Path $BaseTemplateId
        if (-not (Test-Path "$TemplatesRootPath/$TemplateName")) {
            # create the item
            $templateItem = New-Item -Path $TemplatesRootPath -Name $TemplateName -ItemType "{AB86861A-6030-46C5-B394-E8F99E8B87DB}"
            $templateItem."__Icon" = $baseTemplate."__Icon"
            $stdValues = New-Item -Parent $templateItem -Name "__Standard Values" -type $templateItem.ID
            $templateItem."__Standard values" = $stdValues.ID
        } 
        else {
            $templateItem = Get-Item "$TemplatesRootPath/$TemplateName"
        }
        $templateItem."__Base template" = $BaseTemplateId
        $templateItem
    }
}    

function Invoke-ModuleScriptBody {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0 )]
        [Item]$Site,
    
        [Parameter(Mandatory = $true, Position = 1 )]
        [Item[]]$TenantTemplates	
    )
    
    begin {
        Write-Host "Cmdlet Invoke-ModuleScriptBody - Begin"
        Import-Function Get-ProjectTemplateBasedOnBaseTemplate
    }
    
    process {
        Write-Verbose "Cmdlet Invoke-ModuleScriptBody - Process"
        $sitePath = $Site.Paths.Path
        Write-Verbose "My site: $sitePath"

        # handle missing styles folder
        if (-not (Test-Path "$sitePath/Presentation/Styles")) {
            Import-Function Invoke-AddItem
            $action = Get-Item . -ID '{B2486523-7487-4526-978F-AD2E986B5CC4}'
            Invoke-AddItem $Site $action
        }
        
        Write-Verbose "Create page templates in the Site Collection"
        $basePageTemplateId = "{AC9DE9BE-8E86-4147-8FBC-739D5560408B}"
        $baseHomePageTemplateId = "{4ACCF644-A506-421F-B60F-A05E5C6196B4}"
        $baseArticlePageTemplateId = "{B0602368-F67C-433C-8700-862D480546D0}"
        $baseDetailPageTemplateId = "{A9919790-3389-4FC2-ABC8-24F73C847C8E}"
        $baseLandingPageTemplateId = "{C3C9FC9E-E7D3-44E6-B777-AA23496924C7}"
        $baseProductPageTemplateId = "{9A52202D-3A77-4F6D-B9BD-6AECED9BD49A}"
        $basePageFolderTemplateId = "{1105B8F8-1E00-426B-BF1F-C840742D827B}"

        $templatesRootPath = "master:/sitecore/templates/Project/$($SiteCollection.Name)"

        $pageTemplate = Get-Item -Path "$templatesRootPath/Page"
        $pageTemplate."__Base template" = $basePageTemplateId

        $homePageTemplate = Update-PageTemplate -BaseTemplateId $baseHomePageTemplateId -TemplateName "Home Page" -TemplatesRootPath $templatesRootPath
        $articlePageTemplate = Update-PageTemplate -BaseTemplateId $baseArticlePageTemplateId -TemplateName "Article Page" -TemplatesRootPath $templatesRootPath
        $detailPageTemplate = Update-PageTemplate -BaseTemplateId $baseDetailPageTemplateId -TemplateName "Detail Page" -TemplatesRootPath $templatesRootPath
        $landingPageTemplate = Update-PageTemplate -BaseTemplateId $baseLandingPageTemplateId -TemplateName "Landing Page" -TemplatesRootPath $templatesRootPath
        $productPageTemplate = Update-PageTemplate -BaseTemplateId $baseProductPageTemplateId -TemplateName "Product Page" -TemplatesRootPath $templatesRootPath
        $pageFolderTemplate = Update-PageTemplate -BaseTemplateId $basePageFolderTemplateId -TemplateName "Page Folder" -TemplatesRootPath $templatesRootPath
        
        $service = [Sitecore.DependencyInjection.ServiceLocator]::ServiceProvider.GetService([Sitecore.XA.Foundation.Variants.Abstractions.Services.IAvailableRenderingVariantService])
            
        $item = Get-Item -Path "$sitePath/Home" -Language $Site.Language
        
        # Update the home page template
        Set-ItemTemplate -Item $item -Template $homePageTemplate.ID
        Set-ItemTemplate -Path "$sitePath/Home/Products" -Template $pageFolderTemplate.ID
        Set-ItemTemplate -Path "$sitePath/Home/Test Drive" -Template $landingPageTemplate.ID
        Set-ItemTemplate -Path "$sitePath/Home/Products/Aero" -Template $productPageTemplate.ID
        Set-ItemTemplate -Path "$sitePath/Home/Products/Nexa" -Template $productPageTemplate.ID
        Set-ItemTemplate -Path "$sitePath/Home/Products/Terra" -Template $productPageTemplate.ID
        
        
        
        $renderingContainerFullBleed = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Page Structure/Container Full Bleed'
        $renderingHero = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Banners/Hero'
        $renderingTextBanner = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Banners/TextBanner'
        $renderingImageCarousel = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Media/ImageCarousel'
        $renderingPromo = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Promos/Promo'
        $renderingProductListing = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Product/ProductListing'
        $renderingAccordion = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Accordions/Accordion'
    
        # prepare rendering definitions
        $renderingContainerFullBleedDefinition = $renderingContainerFullBleed | New-Rendering
        $renderingHeroDefinition = $renderingHero | New-Rendering
        $renderingTextBannerDefinition = $renderingTextBanner | New-Rendering
        $renderingImageCarouselDefinition = $renderingImageCarousel | New-Rendering
        $renderingPromoDefinition = $renderingPromo | New-Rendering
        $renderingProductListingDefinition = $renderingProductListing | New-Rendering
        $renderingAccordionDefinition = $renderingAccordion | New-Rendering
        
        # prepare rendering variants  
        $heroVariants = $service.GetAvailableRenderingVariants($Site, $renderingHero.Name, $renderingHero.ID, $item.TemplateID)
        $textBannerVariants = $service.GetAvailableRenderingVariants($Site, $renderingTextBanner.Name, $renderingTextBanner.ID, $item.TemplateID)
        $imageCarouselVariants = $service.GetAvailableRenderingVariants($Site, $renderingImageCarousel.Name, $renderingImageCarousel.ID, $item.TemplateID)
        $promoVariants = $service.GetAvailableRenderingVariants($Site, $renderingPromo.Name, $renderingPromo.ID, $item.TemplateID)
        $productListingVariants = $service.GetAvailableRenderingVariants($Site, $renderingProductListing.Name, $renderingProductListing.ID, $item.TemplateID)
        $accordionVariants = $service.GetAvailableRenderingVariants($Site, $renderingAccordion.Name, $renderingAccordion.ID, $item.TemplateID)

        $heroVariant = $heroVariants | ? { $_.DisplayName -eq "Image Background" }
        $textBannerVariant = $textBannerVariants | ? { $_.Name -eq "Default" }
        $imageCarouselVariant = $imageCarouselVariants | ? { $_.Name -eq "Default" }
        $promoVariant = $promoVariants | ? { $_.Name -eq "Default" }
        $productListingVariant = $productListingVariants | ? { $_.Name -eq "Default" }
        $accordionVariant = $accordionVariants | ? { $_.Name -eq "Default" }
        
        # add Home layout
        Add-Rendering -Item $item -PlaceHolder "headless-main" -Instance $renderingContainerFullBleedDefinition -Parameter @{ "DynamicPlaceholderId" = "1"; "excludeTopMargin" = "1" } -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingHeroDefinition -Parameter @{ "FieldNames" = $heroVariant.ID; "DynamicPlaceholderId" = "2" } -DataSource "local:/Data/Home Page Hero" -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingTextBannerDefinition -Parameter @{ "FieldNames" = $textBannerVariant.ID; "DynamicPlaceholderId" = "3" } -DataSource "local:/Data/Home Page Text Banner" -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingImageCarouselDefinition -Parameter @{ "FieldNames" = $imageCarouselVariant.ID; "DynamicPlaceholderId" = "5" } -DataSource "local:/Data/Home Page Image Carousel" -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingPromoDefinition -Parameter @{ "FieldNames" = $promoVariant.ID; "DynamicPlaceholderId" = "4" } -DataSource "local:/Data/Home Page Promo" -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingProductListingDefinition -Parameter @{ "FieldNames" = $productListingVariant.ID } -DataSource "local:/Data/Home Page Product Listing" -FinalLayout
        Add-Rendering -Item $item -PlaceHolder "/headless-main/container-fullbleed-1" -Instance $renderingAccordionDefinition -Parameter @{ "FieldNames" = $accordionVariant.ID; "DynamicPlaceholderId" = "6" } -DataSource "local:/Data/Home Page Accordion" -FinalLayout

        $title = "Alaris - Get set for an electric future."
        $shortTitle = "Alaris"

        $item."pageTitle" = $title
        $item."pageShortTitle" = $shortTitle
        $item."pageHeaderTitle" = $shortTitle
        $item."pageSummary" = $title

        $item."metadataTitle" = $title
        $item."metadataDescription" = $title
        $item."metadataKeywords" = "Alaris, electric, future"
        $item."ogTitle" = $title
        $item."ogDescription" = $title

        # Add Promo variants
        $promoVariant = Get-Item -Path "$sitePath/Presentation/Headless Variants/Promo" -Language $Site.Language
        $imageLeftVariant = New-Item -Parent $promoVariant -Name "ImageLeft" -ItemType "{4D50CDAE-C2D9-4DE8-B080-8F992BFB1B55}"
        $imageLeftVariant.'__Display name' = "Image Left"
        $imageMiddleVariant = New-Item -Parent $promoVariant -Name "ImageMiddle" -ItemType "{4D50CDAE-C2D9-4DE8-B080-8F992BFB1B55}"
        $imageMiddleVariant.'__Display name' = "Image Middle"
        $imageRightVariant = New-Item -Parent $promoVariant -Name "ImageRight" -ItemType "{4D50CDAE-C2D9-4DE8-B080-8F992BFB1B55}"
        $imageRightVariant.'__Display name' = "Image Right"
        $titlePartialOverlayVariant = New-Item -Parent $promoVariant -Name "TitlePartialOverlay" -ItemType "{4D50CDAE-C2D9-4DE8-B080-8F992BFB1B55}"
        $titlePartialOverlayVariant.'__Display name' = "Title Partial Overlay"
        
        # Add Page Design and link partial designs
        $headerPartial = Get-Item -Path "$sitePath/Presentation/Partial Designs/Global/Header" -Language $Site.Language
        $footerPartial = Get-Item -Path "$sitePath/Presentation/Partial Designs/Global/Footer" -Language $Site.Language

        Write-Verbose "Update Partial Design Rendering Variants"
        $renderingGlobalHeader = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Global Elements/GlobalHeader'
        $renderingGlobalFooter = Get-Item -Path '/sitecore/layout/Renderings/Project/click-click-launch/Global Elements/GlobalFooter'
        
        $renderingGlobalHeaderDefinition = $renderingGlobalHeader | New-Rendering
        $renderingGlobalFooterDefinition = $renderingGlobalFooter | New-Rendering

        $globalHeaderVariants = $service.GetAvailableRenderingVariants($Site, $renderingGlobalHeader.Name, $renderingGlobalHeader.ID, $item.TemplateID)
        $globalFooterVariants = $service.GetAvailableRenderingVariants($Site, $renderingGlobalFooter.Name, $renderingGlobalFooter.ID, $item.TemplateID)
        $globalHeaderVariant = $globalHeaderVariants | ? { $_.Name -eq "Centered" }
        $globalFooterVariant = $globalFooterVariants | ? { $_.Name -eq "BlueCompactVariant" }
        
        $globalHeaderRenderingInstance = Get-Rendering -Item $headerPartial -Rendering $renderingGlobalHeader
        if ($globalHeaderRenderingInstance) {
            Set-Rendering -Item $headerPartial -Instance $globalHeaderRenderingInstance -Parameter @{ "FieldNames" = $globalHeaderVariant.ID }
        }
        $globalFooterRenderingInstance = Get-Rendering -Item $footerPartial -Rendering $renderingGlobalFooter
        if ($globalFooterRenderingInstance) {
            Set-Rendering -Item $footerPartial -Instance $globalFooterRenderingInstance -Parameter @{ "FieldNames" = $globalFooterVariant.ID }
        }


        $defaultPageDesign = New-Item -Path "$sitePath/Presentation/Page Designs/" -Name "Default" -ItemType "{1105B8F8-1E00-426B-BF1F-C840742D827B}"
        $defaultPageDesign.PartialDesigns = "$($headerPartial.ID)|$($footerPartial.ID)"

        $pageDesigns = Get-Item -path "$sitePath/Presentation/Page Designs" -Language $Site.Language
        $map = [Sitecore.Text.UrlString]::new()
        $map[$homePageTemplate.ID] = "$($defaultPageDesign.ID)"
        $map[$pageTemplate.ID] = "$($defaultPageDesign.ID)"
        $map[$articlePageTemplate.ID] = "$($defaultPageDesign.ID)"
        $map[$detailPageTemplate.ID] = "$($defaultPageDesign.ID)"
        $map[$landingPageTemplate.ID] = "$($defaultPageDesign.ID)"
        $map[$productPageTemplate.ID] = "$($defaultPageDesign.ID)"
        $pageDesigns.TemplatesMapping = [System.Web.HttpUtility]::UrlEncode($map.toString())
        
        # reset the start item and the rendering host
        $siteName = $Site.Name
        $siteGrouping = Get-Item -Path "$sitePath/Settings/Site Grouping/$($sitename)"
        $siteGrouping.StartItem = $item.ID
        
        $siteGrouping.RenderingHost = "site2"
    }
    
    end {
        Write-Verbose "Cmdlet Invoke-ModuleScriptBody - End"
    }
}