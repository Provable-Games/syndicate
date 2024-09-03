use alexandria_encoding::base64::Base64Encoder;
use core::{array::{SpanTrait, ArrayTrait}, traits::Into, clone::Clone,};
use syndicate::encoding::{bytes_base64_encode, U256BytesUsedTraitImpl};
use graffiti::json::JsonImpl;

// @notice Generates the LS logo svg
// @return The generated LS logo
fn logo() -> ByteArray {
    "<path d=\"M1 2V0h8v2h1v10H7v4H3v-4H0V2zm1 4v4h2v2h2v-2h2V6H6v4H4V6z\"/>"
}

// @notice Generates the crown icon used for top scores
// @return The generated crown icon
fn crown() -> ByteArray {
    "<path d=\"M0 0v7h15V0h-1v1h-1v1h-1v1h-2V2H9V1H8V0H7v1H6v1H5v1H3V2H2V1H1V0H0Z\"/>"
}

// @notice Generates the weapon icon svg
// @return The generated weapon icon
fn argent() -> ByteArray {
    "<path d=\"M97 0H58c-2 0-3 1-3 2-1 39-20 76-54 102l-1 3 24 34h3c21-16 38-35 51-57 12 22 29 41 50 57h3l24-34-1-3c-34-26-53-63-54-102 0-1-1-2-3-2Z\"/>"
}

// @notice Generates the chest icon svg
// @return The generated chest icon
fn defi_spring() -> ByteArray {
    "<path d=\"M131 7h-5l-2 2-2 2-1 2-3 2h-3 1l1 1 1 1h4l2-1a13 13 0 0 0 3-4v-1h1l1-2h4l-2-2Z\" /><path d=\"M124 0c-6 0-12 6-12 13 0 6 6 12 12 12 7 0 13-6 13-12 0-7-6-13-13-13Zm-7 8 1-1 1-1 1 1v1h1l-1 1h-1v1c0 1 0 1 0 0l-1-1-1-1c-1 0-1 0 0 0Zm14 11-2-1 2-2 1 2-1 1Zm2-9a6 6 0 0 0-1 1l-2 2-1 1v1l-3 2-3 2h-4l-3-2a9 9 0 0 1-2-3h4l2-1 2-2 1-2h1V8l2-1 2-1a6 6 0 0 1 6 3l-1 1ZM71 49v-6h13v3h1l5-2v-1l-1-2 1-3v-5l-1-1H64v18h3l4-1Zm0-12h13v1H71v-1ZM93 45v5h6v-7l-6 2ZM99 42V32h-6v12l6-2ZM108 40v-3h10l10-3v-1l-2-1h-24v9l6-1ZM121 37v13h7V35l-7 2ZM102 43v7h6v-9l-6 2ZM130 34v15l2 1h23l1-1V38h-16v5h10v2h-13v-8h19v-5h-19l-7 2Z\"/><path d=\"M165 14c-1-3-8-5-21-4h-5v2l6-1c17-1 19 2 19 3 1 3-11 9-22 13A433 433 0 0 1 27 54c-12 1-25 1-26-2 0-1 0-2 7-6l-1-1c-5 3-7 5-7 8 1 2 5 3 14 3h13a435 435 0 0 0 116-27c15-7 23-12 22-15ZM110 14l-12 3v1l12-3v-1ZM33 27H7V10h25l1 1v16Zm-6-4v-8H14v8h13ZM62 27H36V11l1-1h25v5H42v1h10v5H42v2h13l2-1h5v5ZM90 15H71v1h9v5h-9v6h-7V11l2-1h24v5Z\"/><path d=\"M99 27h-6V10h6v17ZM33 49l-1 1H7v-6h5l2 1h13v-2H9l-2-1v-9l2-1h24v5H14v1h18l1 1v10ZM62 42l-2 1H42v7h-6V32h24l2 1v9Zm-7-4v-1H42v1h13ZM204 49h-37l-2-1V33l2-2h37l2 2v15l-2 1Z\"/><path d=\"M182 38v2h-1v1h-8l-1 1v1h10v2h-13v-4l1-1h1l1-1h7v-1l-1-1h-5l-1 1v1h-3v-2l1-1 3-1h5l3 1 1 1v1ZM184 45v-2h2v2h-2ZM202 39v4a3 3 0 0 1-1 1l-1 1h-2a12 12 0 0 1-1 0h-4l-4-1h-1v-1a3 3 0 0 1 0-1v-4a3 3 0 0 1 1-1l1-1h1l1-1h5l4 1v1h1v1a3 3 0 0 1 0 1Zm-3 2v-3h-1l-2-1h-2l-1 1h-2a1 1 0 0 0 0 1v4h7l1-1v-1Z\"/>"
}

// @notice Generates the head icon svg
// @return The generated head icon
fn dojo() -> ByteArray {
    "<path d=\"M0 0h1v1H0zM1 0h1v1H1zM2 0h1v1H2zM3 0h1v1H3zM4 0h1v1H4zM5 0h1v1H5zM6 0h1v1H6zM1 1h1v1H1zM5 1h1v1H5zM0 2h1v1H0zM1 2h1v1H1zM3 2h1v1H3zM5 2h1v1H5zM6 2h1v1H6zM1 3h1v1H1zM5 3h1v1H5z\"/>"
}

// @notice Generates the waist icon svg
// @return The generated waist icon
fn dope_wars() -> ByteArray {
    "<path d=\"M161 137c4 6 8 6 11 1 4-6 8-13 9-20 1-5 1-11-4-15-4-2-9-2-11 2-4 5-9 10-7 18 1 4 0 9 2 14Zm-34-2c3 0 5-2 7-5 3-7 6-13 4-20 1-5 1-9-1-14-4-6-9-6-14-1-7 8-9 24-4 35 2 3 4 5 8 5Zm67 5c-2-1-6 2-8 5s-1 6 1 8c4 3 2 6 1 9-5 18-18 25-35 29-11 3-23-1-32-7-9-7-15-18-20-29-4-8-7-14 3-20 3-2 5-5 3-9-1-4-5-4-9-4-4 1-9 0-13-2-3-1-6-2-9 1s-1 6 0 9c1 5 6 7 6 12 0 15 6 28 15 40 11 15 25 22 42 26 7 1 13-3 21-1 13 1 23-10 32-19 10-9 10-25 22-32 4-2 4-7 2-11-5-11-15 2-22-5Zm78-23c-1-9-5-19-7-28-3-17-17-30-28-43-4-5-10-12-16-15-17-8-36-14-55-16-18-3-36 1-54 7-5 1-10 1-15 4-13 11-27 18-39 30L47 70c-8 9-11 22-19 30-2 1-2 3-3 5l-4 19c-3 6-6 13-5 20l2 18c3 15 4 30 9 45 2 6 7 11 10 16 12 17 24 34 46 39l10 3c18 10 38 9 57 8 24-2 46-12 64-28 5-4 10-5 14-9 7-12 18-21 24-34l16-39c2-5 3-9 3-14v-8c0-8 2-16 1-24Zm-32 30c-5 29-16 56-43 73-13 10-26 19-44 19-7 1-14 6-22 4-17-2-32-8-47-18-20-12-23-31-34-47v-5c5-12-2-24 0-36 1-11 6-20 10-29 5-13 15-23 25-33 13-13 27-24 46-26 8 0 14-5 21-5 29 2 52 12 70 36 16 21 22 44 18 67Z\"/>"
}

// @notice Generates the foot icon svg
// @return The generated foot icon
fn golden_token() -> ByteArray {
    "<svg viewBox=\"0 0 20000 20000\" xmlns=\"http://www.w3.org/2000/svg\" style=\"background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUAAAAFABAMAAAA/vriZAAAAD1BMVEUAAAD4+ACJSQL/pAD///806TM9AAACgUlEQVR4AWKgGAjiBUqoANDOHdzGDcRQAK3BLaSFtJD+awriQwh8zDd2srlQfjxJGGr4xhfCsuj3ywEC7gcCAgKeCD9bVC8gICAg4HcDVtGvP/G5MKIXvKF8MhAQEBAQMFiformK+Iho8uh8zwMCAgICAk65aouaEVM9WL3zAQICAgJuBqYtth7brEZHC2CcMI6Z1FQCAgICAm4GTnZsGL8WRaW4inPVV3eAgICAgI8CVls0uIr+WnnR7wABAQEBFwAvbBn3ytrvuhIQEBAQcCvwa8IbygCmDRAQEBBwK7DbTt8A/OdWl7ZUAgICAgLuAp5slXD1+i2BzQYICAgIuBsYtigyf82Z+GjRkhMYNQABAQEBdwFfsVXgRLd1YDl/yAEBAQEB9wDrO7OoOQtRvdpeGKecAAQEBATcCsxWd7qNwh1YItG15EYgICAgIOAopyudHp6FuApgTRlgKbkTCAgICAg4jhAl8NCz/u31W2+na4GAgICAgHFVh+ZPtkmJvEiuNeYMa4CAgICAgPlxWSxPnERhS0zE4XDR78rAyw4gICAgIGASYteUN1soJyV+CGOL7QEBAQEBnwTs20yl+tVZvFGLhTpUsxAICAgICJjKfORvvD06OcAL2zogICAgIODJFg+fvknL25vR+7ndCQQEBAQELMrYIeQ/XoxJvrItBAICAgICpvK0w2l8pUak3Nn2AwEBAQEB6z+sj/1jin/yTlsFdT8QEBAQELAro1PF/lEpIlJGHgthAwQEBATcD8wI5dxOzRr1C7POAgQEBAR8GjA7X1SqyjqxP0/cAJYDAQEBAQGDGt46cJ/JyQIEBAQEfD7w0nsl2g8EBAQEBPwNOZbOIEJQph0AAAAASUVORK5CYII=);background-repeat:no-repeat;background-size:contain;background-position:center;image-rendering:-webkit-optimize-contrast;-ms-interpolation-mode:nearest-neighbor;image-rendering:-moz-crisp-edges;image-rendering:pixelated\"/>"
}

// @notice Generates the hand icon svg
// @return The generated hand icon
fn starknet_id() -> ByteArray {
    "<path d=\"M120 80a40 40 0 1 1-80 0 40 40 0 0 1 80 0Z\"/><path d=\"M119 80a39 39 0 0 1-67 28c10 2 36 3 50-14 10-13 8-33 4-43 8 7 13 18 13 29Z\" opacity=\".1\"/><path opacity=\".1\" d=\"M78 21c-18 1-32 5-32 10s16 8 34 7 32-6 32-11c-1-4-16-7-34-6Zm1 14c-16 1-29-1-30-4 0-4 13-8 29-9 17-1 30 2 30 5 1 4-12 7-29 8Z\"/><path d=\"M78 20c-18 1-32 5-32 10s16 8 34 7 32-6 32-11c-1-4-16-7-34-6Zm1 14c-16 1-29-1-30-4 0-4 13-8 29-9 17-1 30 2 30 5 1 4-12 7-29 8ZM47 67s-9 1-10 8c0 0-9 0-12 6l-9 4v3l18 19 1 5s4 5 9 5l7-6s0-5-2-6l-9-4-6-12s12 6 17-6c0-1 9-15-4-16Zm70 0h1c3 1 5 4 6 7 0 0 9 0 13 6l8 3v3l-17 20-1 5s-1 3-6 3l-10-4s0-5 3-6c2-1 7-4 8-3l5-13s-4 2-9 1c2-11 0-15-1-22Z\"/><g><path opacity=\".1\" d=\"M47 67c6 3 5 15-2 13-1 3-2 7-10 6l-6 1 9 15c6 2 11 5 13 9 0 0 0-5-2-6l-9-4-6-12s12 6 17-6c0-1 9-15-4-16ZM117 69s5 3 6 7c0 0 7 1 9 6l3 1-11 19-8 5-3 4-2-1s0-6 3-6l8-4 5-12c-2 1-6 2-9 1 2-7 1-13-1-20Z\"/></g><path opacity=\".6\" d=\"M77 81s0-12 6-12 6 12 6 12-5-12-12 0Zm24 0s0-11 6-11c5 0 5 10 5 10s-5-10-11 1Z\"/><path d=\"M75 85h38s-1 24-19 24c-5 0-10-2-13-6-6-7-6-18-6-18Z\"/><path d=\"M108 101c-3 5-8 7-14 7-5 0-10-2-13-6-6-6 32-8 27-1Z\"/><path d=\"M75 85h38l-1 7s-22 5-36 0l-1-7Z\"/><path d=\"m97 123-5 7-4 3v4c0 1 10-3 9-14Z\"/><path d=\"M98 123s-6-2-9 2c-4 3-4 8-2 8s3 0 11-10Z\"/><path d=\"M124 107s-5-8-20-1c-14 8-2 23-15 31 0 0 3 4 8-6 5-9 5-25 27-24Z\"/><path d=\"M89 137s6 3 10-11 9-22 20-21c2 0 4 0 5 2 5 5 1 19-5 24s-21 11-27 9c-7-2-3-3-3-3Z\"/><path d=\"m88 117 1 8c2-2 3-3 5-3l-1-6-5 1ZM122 111h-11l-1-1h13l-1 1Zm1 3h-14l-1-1h16l-1 1Zm0 3h-18v-1h19l-1 1Zm-1 3h-18v-1h18l1 1h-1Zm-1 3h-18v-1h18l1 1h-1Zm-2 3h-18v-1h18l1 1h-1Zm-2 4h-16v-1h17l-1 1Zm-4 3H99v-1h14v1Zm-5 3H98v-1h10v1Z\"/><path d=\"m63 124-5 7-4 3v4c0 1 10-3 9-14Z\"/><path d=\"m60 113-2 11h4l3-9-5-2Z\"/><path d=\"M64 124s-6-2-9 2c-4 3-4 8-2 8s3 0 11-10Z\"/><path d=\"M90 108s-5-8-20-1c-14 8-2 23-15 31 0 0 3 4 8-6 5-9 5-25 27-24Z\"/><path d=\"M55 138s6 3 10-11 9-22 20-21c2 0 4 0 5 2 5 5 1 19-5 24s-21 11-28 9c-6-2-2-3-2-3Z\"/><path d=\"M88 112H77l-1-1h13l-1 1Zm1 3H75l-1-1h16l-1 1Zm0 3H71v-1h19l-1 1Zm-1 3H70v-1h18l1 1h-1Zm-1 3H69v-1h18l1 1h-1Zm-2 3H67v-1h18l1 1h-1Zm-2 4H67v-1h17l-1 1Zm-4 3H65v-1h14v1Zm-5 3H64v-1h10v1Z\"/>"
}

// @notice Generates the neck icon svg
// @return The generated neck icon
fn starknet() -> ByteArray {
    "<path d=\"M2 79a77 77 0 1 0 154 0A77 77 0 0 0 2 79Z\" stroke-width=\"4\"/><path d=\"m44 60 2-6c1-1 1-2 3-2l6-2v-2l-6-2-3-2-2-6h-1l-2 6-3 2-6 2v2l6 2 3 2 1 6h2Z\" /><path d=\"M140 57c-3-3-7-4-10-5h-12c-8 1-14 4-21 8l-8 7-4 3-3 4-11 10-11 7c-3 2-7 2-11 3l-16-2-19-5c2 6 6 12 11 17 4 6 10 11 18 14 7 3 16 4 25 2 9-1 16-5 23-10a80 80 0 0 0 18-19l2-4 5-6 10-13a55 55 0 0 1 9-9l5-2Z\"/><path d=\"M140 57a35 35 0 0 0-40-21c-4 1-8 2-12 5a53 53 0 0 0-15 12l-3 4-5 7c-7 9-15 20-27 23-12 4-17 1-24 0a39 39 0 0 0 18 21l7 2c4 1 9 2 13 1l14-4 10-7a84 84 0 0 0 21-25l2-3 1-3 8-10c3-2 7-4 13-4s12 0 19 2Z\" /><path d=\"M110 113a9 9 0 1 0 18 0 9 9 0 0 0-18 0Z\"/>"
}

// @notice Generates the ring icon svg
// @return The generated ring icon
fn loot() -> ByteArray {
    "<style>.base { font-family: serif; font-size: 14px; }</style><text class=\"base\">Loot</text>"
}

// @notice Generates a rect element
// @return The generated rect element
fn create_rect() -> ByteArray {
    "<rect x='0.5' y='0.5' width='599' height='899' rx='27.5' fill='black' stroke='#3DEC00'/>"
}

// @notice Generates a text element
// @param text The text to generate a string for
// @param x The x coordinate of the text
// @param y The y coordinate of the text
// @param fontsize The font size of the text
// @param baseline The baseline of the text
// @param text_anchor The text anchor of the text
// @param item_equipped Whether the text represents an equipped item
// @return The generated text element
fn create_text(
    text: ByteArray,
    x: ByteArray,
    y: ByteArray,
    fontsize: ByteArray,
    baseline: ByteArray,
    text_anchor: ByteArray,
) -> ByteArray {
    "<text x='"
        + x
        + "' y='"
        + y
        + "' font-size='"
        + fontsize
        + "' text-anchor='"
        + text_anchor
        + "' dominant-baseline='"
        + baseline
        + "'>"
        + text
        + "</text>"
}

// @notice Creates an item element
// @param x The x coordinate of the item
// @param y The y coordinate of the item
// @param item The item to create
// @return The generated item element
fn create_item_element(
    x: ByteArray, y: ByteArray, width: ByteArray, height: ByteArray, item: ByteArray
) -> ByteArray {
    "<g transform='translate("
        + x
        + ","
        + y
        + ")'><svg width='"
        + width
        + "' height='"
        + height
        + "' viewBox='0 0 200 200'><g transform='scale(0.8)'>"
        + item
        + "</g></svg></g>"
}

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

// @notice Generates an SVG string for adventurer token uri
// @param internals The internals of the SVG
// @return The generated SVG string
fn create_svg(internals: ByteArray) -> ByteArray {
    "<svg xmlns='http://www.w3.org/2000/svg' width='600' height='900'><style>text{text-transform: uppercase;font-family: Courier, monospace;fill: #3DEC00;}g{fill: #3DEC00;}</style>"
        + internals
        + "</svg>"
}

// @notice Generates the logo element
// @return The generated logo element
fn generate_logo() -> ByteArray {
    "<g transform='translate(25,25) scale(4)'>" + logo() + "</g>"
}

// @notice Generates the crown element
// @return The generated crown element
fn generate_crown() -> ByteArray {
    "<g transform='translate(25,17) scale(2.68)' style='fill: #D3AF37;'>" + crown() + "</g>"
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
pub fn create_metadata(token_id: felt252, communityId: u8) -> ByteArray {
    let rect = create_rect();

    let logo_element = generate_logo();
    let crown_element = generate_crown();

    // Combine all elements
    let mut elements = array![
        rect,
        logo_element,
        crown_element,
        create_item_element("25", "240", "50", "50", argent()),
        create_item_element("24", "280", "50", "50", defi_spring()),
        create_item_element("25", "320", "50", "50", dojo()),
        create_item_element("25", "360", "50", "50", dope_wars()),
        create_item_element("25", "400", "50", "50", golden_token()),
        create_item_element("27", "435", "50", "50", loot()),
        create_item_element("25", "475", "50", "50", starknet()),
        create_item_element("25", "515", "50", "50", starknet_id()),
        create_item_element("25", "530", "50", "50", loot()),
    ]
        .span();

    let image = create_svg(combine_elements(ref elements));

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

    #[test]
    fn test_metadata() {
        let metadata = create_metadata(1, 1);
        println!("{}", metadata);
    }
}
