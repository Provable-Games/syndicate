use alexandria_encoding::base64::Base64Encoder;
use core::{array::{SpanTrait, ArrayTrait}, traits::Into, clone::Clone,};
use syndicate::encoding::{bytes_base64_encode, U256BytesUsedTraitImpl};
use graffiti::json::JsonImpl;

// @notice Combines elements into a single string
// @param elements The elements to combine
// @return The combined elements
fn combine_elements(ref elements: Span<ByteArray>) -> ByteArray {
    let mut count: u8 = 1;

    let mut combined: ByteArray = "";
    loop {
        match elements.pop_front() {
            Option::Some(element) => {
                combined += element.clone();

                count += 1;
            },
            Option::None(()) => { break; }
        }
    };

    combined
}

fn svg() -> ByteArray {
    "<svg width=\"500\" height=\"600\" viewBox=\"0 0 500 600\" xmlns=\"http://www.w3.org/2000/svg\">
  <style>text{text-transform: uppercase;font-family: Courier, monospace;fill: #3DEC00;}g{fill: #3DEC00;}</style>
  <rect width=\"100%\" height=\"100%\"/>
  <text x=\"50%\" y=\"90\" text-anchor=\"middle\" font-size=\"48\" fill=\"#3F3\">
        THE SYNDICATE
    </text>
  <path id=\"icon1\" d=\"M219.7 315.4V300h61.6v15.4h7.7v77h-23.1v30.8h-30.8v-30.8H212v-77zm7.7 30.8V377h15.4v15.4h15.4V377h15.4v-30.8h-15.4V377h-15.4v-30.8z\" fill=\"#3F3\"/>
  <path id=\"icon2\" d=\"M123 217v6h3v6h18v-36h6v36h18v-6h3v-6h-6v6h-9v-30h6v-12h-6v6h-6v-6h-6v6h-6v-6h-6v12h6v30h-9v-6z\" fill=\"purple\"/>
  <path id=\"icon3\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M264 156.471v-3h-3v-3h-6v3h3v9h-3v6h-3v3h-3v3h-3v3h-3v3h-6v3h-9v-3h-3v6h3v3h3v3h12v-3h6v-3h3v-3h3v-3h3v-3h3v-3h3v-6h3v-12zm-30 18h3v-3h3v-3h3v-3h3v-3h3v-3h6v-6h-3v-3h-3v3h-6v3h-3v3h-3v3h-3v3h-3v3h-3v6h-3v3h3v3h6z\" fill=\"yellow\"/>
  <path id=\"icon4\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M367 202.471v3h-3v9h-12v-3h9v-27h-3v21h-3v-24h-3v24h-3v-21h-3v24h-3v-15h-3v30h3v6h15v-3h6v-3h3v-6h3v-15z\" fill=\"gray\"/>
  <path id=\"icon5\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M395 296.471h6v-3h-6zm9-9v-9h-3v3h-3v6h-3v3h12v-3zm6-12h-3v12h3zm18 0v12h3v-12zm12 12v-6h-3v-3h-3v9h-3v3h12v-3zm-3 9h6v-3h-6zm-15-3h-6v-3h-9v3h-3v12h12v-3h6v3h12v-12h-3v-3h-9zm3 18v3h3v6h3v-6h3v-6h-12v3zm-9-3h6v-3h-6zm0 3v-3h-12v6h3v6h3v-6h3v-3zm6 0h-6v3h-3v6h12v-6h-3z\" fill=\"green\"/>
  <path id=\"icon6\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M408.5 380.471v-3h-12v6h15v-3zm9-3h-6v3h6zm0 6h-6v3h6zm0 9v-3h-6v3zm0 6v-3h-6v3zm0 6v-3h-6v3zm15 0v-3h-6v3zm0-6v-3h-6v3zm0-6v-3h-6v3zm0-9h-6v3h6zm0-6h-6v3h6zm-9 3v-3h-3v6h6v-3zm0 21h3v-3h-3v-3h3v-3h-3v-3h3v-3h-6v18h3zm-6 9v-3h-6v-3h-3v-3h3v-3h-3v-3h3v-3h-3v-3h3v-3h-15v30h18v-6zm15 0h-3v-3h-9v3h-3v6h-3v3h21v-6h-3zm-36 15h15v-3h3v-3h-18zm39 0v-3h-21v3zm3 0h12v-3h-12zm9-12v-3h-3v-3h-6v3h-3v3h3v6h12v-6zm-12-6h-3v3h3zm-331.5-123h-3v-3h-6v-3H83v3h-6v3h-3v6h-3v30h3v3h3v3h6v-12h-3v-6h-3v-3h-3v-6h12v12h6v-12h12v6h-3v3h-3v6h-3v12h6v-3h3v-3h3v-30h-3zm-39 0v-3h-3v-3h-3v9h3v6h3v3h3v-6h3v-6zm51-6v3h-3v3h-6v6h3v6h3v-3h3v-6h3v-9z\" fill=\"blue\"/>
  <path id=\"icon7\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M270 526.471v-6h-3v-3h-3v-3h-3v-3h-3v-3h-6v-3h-18v3h-3v3h-3v24h3v3h3v3h12v-3h3v-3h-12v-3h-3v-18h3v-3h12v3h6v3h3v3h3v3h3v3h3v3h-6v3h3v3h6v-3h3v-6zm-18 9v3h3v-3zm3 0h6v-3h-6zm12 9v-6h-3v6zm-18-6v6h3v-6zm6 12h6v-3h-6zm-3-6v3h3v-3zm9 3h3v-3h-3zm0-9h3v-3h-3zm-6 6h6v-6h-6z\" fill=\"purple\"/>
  <path id=\"icon8\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M128 511.471h6v-3h-6zm0-6h9v-3h-9zm3-18h-3v12h9v-3h3v-12h-9zm0-6h9v-6h-9zm12 0h3v-3h3v3h3v-6h-9zm21-6h-9v6h9zm0 12v-3h-9v12h3v3h9v-12zm-6 18h9v-3h-9zm3 6h6v-3h-6zm-18-12h3v3h3v-3h3v-15h-9z\" fill=\"yellow\"/>
  <path id=\"icon9\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M89 386.471v-3h-6v-3h-3v-3h-6v6h-3v6h-3v3h6v-3h6v6h-3v6h-3v6h-3v6h-3v6h-3v6h6v-6h3v-6h3v-6h3v-6h3v-6h6v15h6v-6h3v-6h3v-6h3v-6z\" fill=\"gray\"/>
  <path id=\"icon10\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M373.5 481.471v-3h-3v-3h-9v3h-3v3h-3v3h-3v-3h-3v-3h-3v-3h-9v3h-3v3h-3v12h3v6h3v3h3v3h3v3h3v3h3v3h3v3h3v-3h3v-3h3v-3h3v-3h3v-3h3v-3h3v-6h3v-12z\" fill=\"green\"/>
</svg>"
}

fn svg_win() -> ByteArray {
    "<svg width=\"500\" height=\"600\" viewBox=\"0 0 500 600\" xmlns=\"http://www.w3.org/2000/svg\">
  <style>text{text-transform: uppercase;font-family: Courier, monospace;fill: #3DEC00;}g{fill: #3DEC00;}</style>
  <rect width=\"100%\" height=\"100%\"/>
  <text x=\"50%\" y=\"90\" text-anchor=\"middle\" font-size=\"48\" fill=\"#3F3\">
        THE SYNDICATE
    </text>
  <path id=\"icon1\" d=\"M219.7 315.4V300h61.6v15.4h7.7v77h-23.1v30.8h-30.8v-30.8H212v-77zm7.7 30.8V377h15.4v15.4h15.4V377h15.4v-30.8h-15.4V377h-15.4v-30.8z\" fill=\"#3F3\"/>
  <polygon fill-rule=\"evenodd\" clip-rule=\"evenodd\" points=\"220,300 220,275 225,275 225,280 230,280 230,285 235,285 235,280 240,280 240,275 245,275 245,270 250,270 256,270 256,275 261,275 261,280 266,280 266,285 271,285 271,280 276,280 276,275 281,275 281,300 \" fill=\"gold\"/>
  <path id=\"icon2\" d=\"M123 217v6h3v6h18v-36h6v36h18v-6h3v-6h-6v6h-9v-30h6v-12h-6v6h-6v-6h-6v6h-6v-6h-6v12h6v30h-9v-6z\" fill=\"purple\"/>
  <path id=\"icon3\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M264 156.471v-3h-3v-3h-6v3h3v9h-3v6h-3v3h-3v3h-3v3h-3v3h-6v3h-9v-3h-3v6h3v3h3v3h12v-3h6v-3h3v-3h3v-3h3v-3h3v-3h3v-6h3v-12zm-30 18h3v-3h3v-3h3v-3h3v-3h3v-3h6v-6h-3v-3h-3v3h-6v3h-3v3h-3v3h-3v3h-3v3h-3v6h-3v3h3v3h6z\" fill=\"yellow\"/>
  <path id=\"icon4\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M367 202.471v3h-3v9h-12v-3h9v-27h-3v21h-3v-24h-3v24h-3v-21h-3v24h-3v-15h-3v30h3v6h15v-3h6v-3h3v-6h3v-15z\" fill=\"gray\"/>
  <path id=\"icon5\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M395 296.471h6v-3h-6zm9-9v-9h-3v3h-3v6h-3v3h12v-3zm6-12h-3v12h3zm18 0v12h3v-12zm12 12v-6h-3v-3h-3v9h-3v3h12v-3zm-3 9h6v-3h-6zm-15-3h-6v-3h-9v3h-3v12h12v-3h6v3h12v-12h-3v-3h-9zm3 18v3h3v6h3v-6h3v-6h-12v3zm-9-3h6v-3h-6zm0 3v-3h-12v6h3v6h3v-6h3v-3zm6 0h-6v3h-3v6h12v-6h-3z\" fill=\"green\"/>
  <path id=\"icon6\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M408.5 380.471v-3h-12v6h15v-3zm9-3h-6v3h6zm0 6h-6v3h6zm0 9v-3h-6v3zm0 6v-3h-6v3zm0 6v-3h-6v3zm15 0v-3h-6v3zm0-6v-3h-6v3zm0-6v-3h-6v3zm0-9h-6v3h6zm0-6h-6v3h6zm-9 3v-3h-3v6h6v-3zm0 21h3v-3h-3v-3h3v-3h-3v-3h3v-3h-6v18h3zm-6 9v-3h-6v-3h-3v-3h3v-3h-3v-3h3v-3h-3v-3h3v-3h-15v30h18v-6zm15 0h-3v-3h-9v3h-3v6h-3v3h21v-6h-3zm-36 15h15v-3h3v-3h-18zm39 0v-3h-21v3zm3 0h12v-3h-12zm9-12v-3h-3v-3h-6v3h-3v3h3v6h12v-6zm-12-6h-3v3h3zm-331.5-123h-3v-3h-6v-3H83v3h-6v3h-3v6h-3v30h3v3h3v3h6v-12h-3v-6h-3v-3h-3v-6h12v12h6v-12h12v6h-3v3h-3v6h-3v12h6v-3h3v-3h3v-30h-3zm-39 0v-3h-3v-3h-3v9h3v6h3v3h3v-6h3v-6zm51-6v3h-3v3h-6v6h3v6h3v-3h3v-6h3v-9z\" fill=\"blue\"/>
  <path id=\"icon7\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M270 526.471v-6h-3v-3h-3v-3h-3v-3h-3v-3h-6v-3h-18v3h-3v3h-3v24h3v3h3v3h12v-3h3v-3h-12v-3h-3v-18h3v-3h12v3h6v3h3v3h3v3h3v3h3v3h-6v3h3v3h6v-3h3v-6zm-18 9v3h3v-3zm3 0h6v-3h-6zm12 9v-6h-3v6zm-18-6v6h3v-6zm6 12h6v-3h-6zm-3-6v3h3v-3zm9 3h3v-3h-3zm0-9h3v-3h-3zm-6 6h6v-6h-6z\" fill=\"purple\"/>
  <path id=\"icon8\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M128 511.471h6v-3h-6zm0-6h9v-3h-9zm3-18h-3v12h9v-3h3v-12h-9zm0-6h9v-6h-9zm12 0h3v-3h3v3h3v-6h-9zm21-6h-9v6h9zm0 12v-3h-9v12h3v3h9v-12zm-6 18h9v-3h-9zm3 6h6v-3h-6zm-18-12h3v3h3v-3h3v-15h-9z\" fill=\"yellow\"/>
  <path id=\"icon9\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M89 386.471v-3h-6v-3h-3v-3h-6v6h-3v6h-3v3h6v-3h6v6h-3v6h-3v6h-3v6h-3v6h-3v6h6v-6h3v-6h3v-6h3v-6h3v-6h6v15h6v-6h3v-6h3v-6h3v-6z\" fill=\"gray\"/>
  <path id=\"icon10\" fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M373.5 481.471v-3h-3v-3h-9v3h-3v3h-3v3h-3v-3h-3v-3h-3v-3h-9v3h-3v3h-3v12h3v6h3v3h3v3h3v3h3v3h3v3h3v3h3v-3h3v-3h3v-3h3v-3h3v-3h3v-3h3v-6h3v-12z\" fill=\"green\"/>
  
  <script type=\"text/javascript\">
    <![CDATA[
      function rotateColors() {
        const icons = [
          'icon2', 'icon3', 'icon4', 'icon5', 'icon6',
          'icon7', 'icon8', 'icon9', 'icon10'
        ];
        const colorPattern = [
          'purple', 'yellow', 'gray', 'green', 'blue'
        ];
        
        let currentShift = 0;
        
        setInterval(() => {
          icons.forEach((iconId, index) => {
            const icon = document.getElementById(iconId);
            const colorIndex = (index - currentShift + colorPattern.length) % colorPattern.length;
            icon.setAttribute('fill', colorPattern[colorIndex]);
          });
          
          currentShift = (currentShift + 1) % colorPattern.length;
        }, 1000); // Change colors every 1 second
      }
      
      // Start the color rotation when the SVG loads
      document.addEventListener('DOMContentLoaded', rotateColors);
    ]]>
  </script>
</svg>"
}

fn create_svg(internals: ByteArray) -> ByteArray {
    "<svg xmlns='http://www.w3.org/2000/svg' width='600' height='900'><style>text{text-transform: uppercase;font-family: Courier, monospace;fill: #3DEC00;}g{fill: #3DEC00;}</style>"
        + internals
        + "</svg>"
}

fn get_community_name(communityId: u8) -> ByteArray {
    let mut community_name: ByteArray = "";
    if (communityId == 1) {
        community_name = "Dojo";
    } else if (communityId == 2) {
        community_name = "Starkware";
    } else if (communityId == 3) {
        community_name = "Argent";
    } else if (communityId == 4) {
        community_name = "Dope Wars";
    } else if (communityId == 5) {
        community_name = "1337";
    } else if (communityId == 6) {
        community_name = "Stark ID";
    } else if (communityId == 7) {
        community_name = "Defi Spring";
    } else if (communityId == 8) {
        community_name = "Golden Token";
    } else if (communityId == 9) {
        community_name = "Loot";
    }

    community_name
}

/// @title Create Metadata
/// @author Syndicate
/// @notice Generates a metadata string for an adventurer token
/// @param token_id The token ID
/// @param community The community name
/// @return The metadata string
pub fn create_metadata(token_id: felt252, communityId: u8, win: bool) -> ByteArray {
    let image = if win {
        svg_win()
    } else {
        svg()
    };

    let base64_image = format!("data:image/svg+xml;base64,{}", bytes_base64_encode(image));

    let mut metadata = JsonImpl::new()
        // TODO: switch to dynamic token id
        .add("name", "Syndicate" + "# " + "1")
        .add(
            "description",
            "A Syndicate of top Web3 communities, initially assembled for the purpose of winning the Loot Survivor launch tournament."
        )
        .add("image", base64_image);

    let community: ByteArray = JsonImpl::new()
        .add("trait", "community")
        .add("value", get_community_name(communityId))
        .build();

    let attributes = array![community,].span();

    let metadata = metadata.add_array("attributes", attributes).build();

    format!("data:application/json;base64,{}", bytes_base64_encode(metadata))
}


#[cfg(test)]
mod tests {
    use core::array::ArrayTrait;
    use super::{create_metadata};
    use snforge_std::{start_cheat_block_timestamp_global};
}
