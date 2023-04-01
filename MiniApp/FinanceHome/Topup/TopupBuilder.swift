//
//  TopupBuilder.swift
//  MiniApp
//
//  Created by no1true on 2023/03/26.
//

import ModernRIBs

protocol TopupDependency: Dependency {
    // TODO: Make sure to convert the variable into lower-camelcase.
    var topupBaseViewController: ViewControllable { get }
    var cardOnFileRepository: CardOnFileRepository { get }
    var superPayRepository: SuperPayRepository { get }
}

final class TopupComponent: Component<TopupDependency>, TopupInteractorDependency, AddPaymentMethodDependency,
EnterAmountDependency, CardOnFileDependency
{
    var superPayRepository: SuperPayRepository { dependency.superPayRepository }
    
    var selectedPaymentMethod: ReadOnlyCurrentValuePublisher<PaymentMethod> { paymentMethodStream }
    
    var cardOnFileRepository: CardOnFileRepository { dependency.cardOnFileRepository }
    fileprivate var TopupBaseViewController: ViewControllable { dependency.topupBaseViewController }
    
    let paymentMethodStream: CurrentValuePublisher<PaymentMethod>
    
    init(
        dependency: TopupDependency,
        paymentMethodStream: CurrentValuePublisher<PaymentMethod>
    ) {
        self.paymentMethodStream = paymentMethodStream
        super.init(dependency: dependency)
    }
}

// MARK: - Builder

protocol TopupBuildable: Buildable {
    func build(withListener listener: TopupListener) -> TopupRouting
}

final class TopupBuilder: Builder<TopupDependency>, TopupBuildable {

    override init(dependency: TopupDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: TopupListener) -> TopupRouting {
        let paymentMethodStream = CurrentValuePublisher(PaymentMethod(id: "", name: "", digits: "", color: "", isPrimary: false))
        
        let component = TopupComponent(dependency: dependency, paymentMethodStream: paymentMethodStream)
        let interactor = TopupInteractor(dependency: component)
        interactor.listener = listener
        
        let addPaymentMethodBuilder = AddPaymentMethodBuilder(dependency: component)
        let enterAmountBuilder = EnterAmountBuilder(dependency: component)
        let cardOnFileBuilder = CardOnFileBuilder(dependency: component)
        return TopupRouter(
            interactor: interactor,
            viewController: component.TopupBaseViewController,
            addPaymentMethodBuildable: addPaymentMethodBuilder,
            enterAmountBuildable: enterAmountBuilder,
            cardOnFileBuildable: cardOnFileBuilder
        )
    }
}
