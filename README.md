# smart-contracts

# TL;DR
An ERC20 token standard compliant “Emission Token” that uses blockchain technology to enable a decentralized emissions trading system, coded as a smart contract in Solidity and deployed on the Ethereum test net.

# Limitations to the implementation
The code is mostly to be understood as proof of concept. Some challenges that remain include:
- The initial distribution of emissions. In a real world scenario, a government would deal with the distribution according to different criteria such as historical production and others. So far, the contract creator initially gets all the emission tokens, and its up to him to transfer them. A way to deal with this could be some form of initial distribution similar to ICOs (initial coin offerings) or STO (security token offerings).
- The registration of holders (e.g. institutions or firms which have a total emission balance) and associates (their subordinated parts, like a firm’s factory, which decrease that balance by emitting green house gases). In this implementation, the smart contract only allows holders to register their associates. This makes sense for example because it prevents competing businesses from registering smart meters to their rivals in order to decrease their emission balance. However, it does not solve the problem of an entity just deciding to cheat by not registering an associate to save emissions.
- Automated punishments and regulations are not included yet. A spontaneous idea that just sprung to my mind is a decentralized way to let all participants regulate each other, maybe by appointing a suspected cheater and suspending him from the exchange for a set period of time when enough participants vote to do so. This would incentivize clean playing, but at the same time introduce mistrust between parties into the game.

# Learnings
I initially planned to implement the whole transaction process, including tokens and compensation in form of Ether. Instead of transfer functions I had functions to sell and buy emissions, and a global conversionRate variable to calculate the price for each transaction. But I quickly ran against a wall here, because to do this I needed to match seller and buyer, having to implement a whole marketplace. This made me stumble upon the ERC20 token standard which delegates this to a third party using an approval mechanism.
