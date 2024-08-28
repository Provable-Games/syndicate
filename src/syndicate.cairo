use core::starknet::ContractAddress;

#[starknet::contract]
mod Syndicate {
    use super::IERC721Mixin;
    use core::starknet::{ContractAddress, contract_address_const};
    use openzeppelin_token::erc721::erc721::ERC721Component::InternalTrait;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_introspection::src5::SRC5Component;

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    impl SRC5 = SRC5Component::SRC5Impl<ContractState>;
    impl ERC721 = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721Metadata = ERC721Component::ERC721MetadataImpl<ContractState>;
    impl ERC721CamelOnly = ERC721Component::ERC721CamelOnlyImpl<ContractState>;
    impl ERC721MetadataCamelOnly = ERC721Component::ERC721MetadataCamelOnlyImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState,) {
        self.erc721.initializer("The Syndicate", "SYN", "");
    }

    #[abi(embed_v0)]
    impl ERC721Mixin of super::IERC721Mixin<ContractState> {
        // IERC721
        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            ERC721::balance_of(self, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            ERC721::owner_of(self, token_id)
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            ERC721::safe_transfer_from(ref self, from, to, token_id, data);
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            ERC721::transfer_from(ref self, from, to, token_id);
        }

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            ERC721::approve(ref self, to, token_id);
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            ERC721::set_approval_for_all(ref self, operator, approved);
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            ERC721::get_approved(self, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721::is_approved_for_all(self, owner, operator)
        }

        // IERC721Metadata
        fn name(self: @ContractState) -> ByteArray {
            ERC721Metadata::name(self)
        }

        fn symbol(self: @ContractState) -> ByteArray {
            ERC721Metadata::symbol(self)
        }

        fn token_uri(self: @ContractState, token_id: u256) -> ByteArray {
            self.erc721._require_owned(token_id);
            "todo"
        }

        // IERC721CamelOnly
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            ERC721CamelOnly::balanceOf(self, account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::ownerOf(self, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            ERC721CamelOnly::safeTransferFrom(ref self, from, to, tokenId, data);
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            ERC721CamelOnly::transferFrom(ref self, from, to, tokenId);
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            ERC721CamelOnly::setApprovalForAll(ref self, operator, approved);
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            ERC721CamelOnly::getApproved(self, tokenId)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            ERC721CamelOnly::isApprovedForAll(self, owner, operator)
        }

        // IERC721MetadataCamelOnly
        fn tokenURI(self: @ContractState, tokenId: u256) -> ByteArray {
            Self::token_uri(self, tokenId)
        }

        // ISRC5 snake case
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            SRC5::supports_interface(self, interface_id)
        }

        // ISRC5 camel case
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            SRC5::supports_interface(self, interfaceId)
        }

        fn airdrop(ref self: ContractState) {
            _airdrop(ref self);
        }
    }

    fn _airdrop(ref self: ContractState) -> u16 {
        let mut token_count: u16 = 1;

        // mint dojo syndicate addresses
        let mut dojo_addresses = get_dojo_addresses();
        loop {
            match dojo_addresses.pop_front() {
                Option::Some(address) => {
                    self.erc721.mint(*address, token_count.into());
                    token_count += 1;
                    break;
                },
                Option::None(_) => { break; }
            };
        };

        token_count
    }

    #[inline(always)]
    pub fn get_dojo_addresses() -> Span<ContractAddress> {
        array![
            contract_address_const::<
                0x02c3F466e4e8C0255ff52ade0E4fC7E8024CCd8c530e58FB888C2d0D7BcF11B6
            >(),
            contract_address_const::<
                0x03C63FFBBB09b7E7D74F85e95c85255829Ad79b59E3D63Cb66E635c12fFAf08b
            >(),
            contract_address_const::<
                0x064fd0b4e9b1e0d61a13d431f59ddfeaa49fcd4f48aad799b5dfd5fedb45e77c
            >(),
            contract_address_const::<
                0x02Bc9bbD6aBdFc745918827D9438052d854F079F3Dd91739B45dfbe5B0f54B5C
            >(),
            contract_address_const::<
                0x069213226154069d250944a7CC15140BC45039924b9BbCda7Be4F15227654eC6
            >(),
            contract_address_const::<
                0x04e1E065942E03C1BaF4EBFF3563cee4230c83c3e53598800b8553FB3348b421
            >(),
            contract_address_const::<
                0x008b0aC0621b55aaa1E7F568C4CE66C3D078dd37849eE3a8d366bd89e0439a86
            >(),
            contract_address_const::<
                0x02CD97240DB3f679De98A729aE91EB996cAb9Fd92a9A578Df11a72F49bE1c356
            >(),
            contract_address_const::<
                0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x065d2AB17338b5AffdEbAF95E2D79834B5f30Bac596fF55563c62C3c98700150
            >(),
            contract_address_const::<
                0x02dD93bcFc6DcB21083f9E045066c54A45e0AEFB00a6C79eB5286eE0e1801504
            >(),
            contract_address_const::<
                0x0013588bbA0f78e623497f52702ca3ECF420fc82c032182473DB95b9DC0bFe33
            >(),
            contract_address_const::<
                0x058E058Cc515404046B9A125531b92DFB9542B02829447381483520Df7E7E39e
            >(),
            contract_address_const::<
                0x0643948eef68D67CBd9A1853b6181B83f15D06953724Fd5347e922d40245B93C
            >(),
            contract_address_const::<
                0x069213226154069d250944a7CC15140BC45039924b9BbCda7Be4F15227654eC6
            >(),
            contract_address_const::<
                0x0628b9dE919e8d1Cfb31A4e435E0CA27F33a8DC71b7475fD1a122222A6eb2f89
            >(),
            contract_address_const::<
                0x02c3F466e4e8C0255ff52ade0E4fC7E8024CCd8c530e58FB888C2d0D7BcF11B6
            >(),
            contract_address_const::<
                0x0082Ab51630d38aa639599165B08CE9e92208de7A9f4a0b3147bfABE6D3eB763
            >(),
            contract_address_const::<
                0x0291c1dfe2ab9858fadf1000f2c0c14fd197fc56483239dc5e7d4a42be8efe04
            >(),
            contract_address_const::<
                0x03d87EE70baf292Cdc23C654153cFD711fF580a076d1dccc0dfd9D3eb62DF311
            >(),
            contract_address_const::<
                0x064fd0b4e9b1e0d61a13d431f59ddfeaa49fcd4f48aad799b5dfd5fedb45e77c
            >(),
            contract_address_const::<
                0x06F490C0ec49FE17148af6F83eBEBd9d31E5a06dC46BDBE5c5E0657c23A4fF4F
            >(),
            contract_address_const::<
                0x04645f67e3e195420b2b4e63742153623e50c143ed8b89c91e3fb908fe87b168
            >(),
            contract_address_const::<
                0x0695A65AF5F0f019153237122256401e65A15c9B53B86705A0F40CF59f8681BC
            >(),
            contract_address_const::<
                0x02CD97240DB3f679De98A729aE91EB996cAb9Fd92a9A578Df11a72F49bE1c356
            >(),
            contract_address_const::<
                0x02Bc9bbD6aBdFc745918827D9438052d854F079F3Dd91739B45dfbe5B0f54B5C
            >(),
            contract_address_const::<
                0x071538f6445e0c6179b786230a3e7b5ddee40b72673a9b5a395da20f4657bdca
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x06a519DCcd7Ed4D1aACD3975691AEEae47bF7f9F5b62Ed7C2D929D2E27A9CC5E
            >(),
            contract_address_const::<
                0x04042b3F651F6d6Ff03b929437AdC30257333723970071b05cb0E2270C9dc385
            >(),
            contract_address_const::<
                0x06a519DCcd7Ed4D1aACD3975691AEEae47bF7f9F5b62Ed7C2D929D2E27A9CC5E
            >(),
            contract_address_const::<
                0x06e493eaf86D4542dc26f11876693b9C330B3921eD47cC91D14A18e66B2e27Dd
            >(),
        ]
            .span()
    }
}

#[starknet::interface]
pub trait IERC721Mixin<TState> {
    fn balance_of(self: @TState, account: ContractAddress) -> u256;

    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;

    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );

    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);

    fn approve(ref self: TState, to: ContractAddress, token_id: u256);

    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);

    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;

    fn is_approved_for_all(
        self: @TState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;

    // IERC721Metadata
    fn name(self: @TState) -> ByteArray;

    fn symbol(self: @TState) -> ByteArray;

    fn token_uri(self: @TState, token_id: u256) -> ByteArray;

    // IERC721CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;

    fn ownerOf(self: @TState, tokenId: u256) -> ContractAddress;

    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        data: Span<felt252>
    );

    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, tokenId: u256);

    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);

    fn getApproved(self: @TState, tokenId: u256) -> ContractAddress;

    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;

    // IERC721MetadataCamelOnly
    fn tokenURI(self: @TState, tokenId: u256) -> ByteArray;

    // ISRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    fn supportsInterface(self: @TState, interfaceId: felt252) -> bool;

    fn airdrop(ref self: TState);
}

#[cfg(test)]
mod tests {
    use core::num::traits::Zero;
    use snforge_std::{
        declare, ContractClassTrait, start_cheat_caller_address_global,
        stop_cheat_caller_address_global
    };
    use super::{IERC721MixinDispatcher, IERC721MixinDispatcherTrait, Syndicate::get_dojo_addresses};

    #[test]
    fn test_erc721_basic_functionality() {
        let contract = declare("Syndicate").unwrap();
        let (contract_address, _) = contract.deploy(@array![]).unwrap();

        // Create a dispatcher
        let dispatcher = IERC721MixinDispatcher { contract_address };
        dispatcher.airdrop();

        // Test address
        let owner = starknet::contract_address_const::<
            0x02c3F466e4e8C0255ff52ade0E4fC7E8024CCd8c530e58FB888C2d0D7BcF11B6
        >();

        // Check balance and ownership
        let owner_balance = dispatcher.balance_of(owner);
        assert(owner_balance == 1, 'Invalid owner balance');

        let token_owner = dispatcher.owner_of(1);
        assert(token_owner == owner, 'Invalid token owner');

        // Transfer the token
        start_cheat_caller_address_global(owner);
        let recipient = starknet::contract_address_const::<0x2>();
        dispatcher.transfer_from(owner, recipient, 1);
        stop_cheat_caller_address_global();

        // Check updated balances and ownership
        let new_owner_balance = dispatcher.balance_of(owner);
        assert(new_owner_balance == 0, 'Invalid new owner balance');

        let recipient_balance = dispatcher.balance_of(recipient);
        assert(recipient_balance == 1, 'Invalid recipient balance');

        let new_token_owner = dispatcher.owner_of(1);
        assert(new_token_owner == recipient, 'Invalid new token owner');

        // Check token URI
        let token_uri = dispatcher.token_uri(1);
        assert(token_uri == "todo", 'Invalid token URI');

        // Check name and symbol
        let name = dispatcher.name();
        assert(name == "The Syndicate", 'Invalid name');

        let symbol = dispatcher.symbol();
        assert(symbol == "SYN", 'Invalid symbol');
    }
}
