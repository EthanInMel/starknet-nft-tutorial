// SPDX-License-Identifier: MIT

#[starknet::interface]
pub trait IMintableBurnable<ContractState> {
    fn mint(ref self: ContractState) -> u256;
    fn burn(ref self: ContractState, token_id: u256);
}

#[starknet::contract]
pub mod ERC721Enumerable {
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::ERC721Component;
    use openzeppelin::token::erc721::extensions::ERC721EnumerableComponent;
    use starknet::{get_contract_address, get_caller_address};
    use starknet::{ContractAddress};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: ERC721EnumerableComponent, storage: erc721_enumerable, event: ERC721EnumerableEvent);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        erc721_enumerable: ERC721EnumerableComponent::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        cur_token_id: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        ERC721EnumerableEvent: ERC721EnumerableComponent::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
    }

    // ERC721
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721Impl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;

    // ERC721Enumerable
    #[abi(embed_v0)]
    impl ERC721EnumerableImpl = ERC721EnumerableComponent::ERC721EnumerableImpl<ContractState>;
    impl ERC721EnumerableInternalImpl = ERC721EnumerableComponent::InternalImpl<ContractState>;

    // SRC5
    #[abi(embed_v0)]
    impl SRC5Impl = SRC5Component::SRC5Impl<ContractState>;

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
    ) {
        self.erc721.initializer(name, symbol, base_uri);
        self.erc721_enumerable.initializer();
    }

    impl ERC721HooksImpl of ERC721Component::ERC721HooksTrait<ContractState> {
        fn before_update(
            ref self: ERC721Component::ComponentState<ContractState>,
            to: ContractAddress,
            token_id: u256,
            auth: ContractAddress
        ) {
            let mut contract_state = ERC721Component::HasComponent::get_contract_mut(ref self);
            contract_state.erc721_enumerable.before_update(to, token_id);
        }
    }

    #[abi(embed_v0)]
    pub impl MintableBurnableImpl of super::IMintableBurnable<ContractState> {

        fn mint(ref self: ContractState) -> u256 {
            let caller = get_caller_address();
            self.cur_token_id.write(self.cur_token_id.read() + 1);
            self.erc721.mint(caller, self.cur_token_id.read());
            self.cur_token_id.read()
        }

        fn burn(ref self: ContractState, token_id: u256) {
            let caller = get_caller_address();            
            assert!(self.erc721.owner_of(token_id) == caller, "only owner can burn");
            self.erc721.burn(token_id);
        }
    }
}
