//
//  TopupInteractor.swift
//  MiniApp
//
//  Created by no1true on 2023/03/26.
//

import ModernRIBs

protocol TopupRouting: Routing {
    func cleanupViews()
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachAddPaymentMethod(closeButtonType: DismissButtonType)
    func detachAddPaymentMehtod()
    func attachEnterAmount()
    func detachEnterAmount()
    func attachCardOnFile(paymentMethods: [PaymentMethod])
    func detachCardOnFile()
    func popToRoot()
}

protocol TopupListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func topupDidClose()
    func topupDidFinish()
}

protocol TopupInteractorDependency {
    var cardOnFileRepository: CardOnFileRepository{ get }
    var paymentMethodStream: CurrentValuePublisher<PaymentMethod> { get }
}

final class TopupInteractor: Interactor, TopupInteractable, AddPaymentMethodListener, AdaptivePresentationControllerDelegate {
    weak var router: TopupRouting?
    weak var listener: TopupListener?
    
    let presentationDelegateProxy:AdaptivePresentationControllerDelegateProxy
    
    private var isEnterAmountRoot: Bool = false
    
    private var paymentMethods: [PaymentMethod] {
        dependency.cardOnFileRepository.cardOnFile.value
    }
    
    private let dependency: TopupInteractorDependency
    init(
        dependency: TopupInteractorDependency
    ) {
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        self.dependency = dependency
        super.init()
        self.presentationDelegateProxy.delegate = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        if let card = dependency.cardOnFileRepository.cardOnFile.value.first {
            isEnterAmountRoot = true
            dependency.paymentMethodStream.send(card)
            // 금액 입력 화면
            router?.attachEnterAmount()
        } else {
            // 카드 추가 확면
            isEnterAmountRoot = false
            router?.attachAddPaymentMethod(closeButtonType: .close)
        }
    }
    
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }
    
    func presentationControllerDidDismiss() {
        listener?.topupDidClose()
    }
    func addPaymentMethodDidTapClose() {
        router?.detachAddPaymentMehtod()
        if isEnterAmountRoot == false {
            listener?.topupDidClose()
        }
    }
    func addPaymentMethodDidAddCard(paymentMethod: PaymentMethod) {
        dependency.paymentMethodStream.send(paymentMethod)
        if isEnterAmountRoot {
            router?.popToRoot()
        } else {
            isEnterAmountRoot = true
            router?.attachEnterAmount()
        }
    }
    
    func enterAmountDidTapClose() {
        router?.detachEnterAmount()
        listener?.topupDidClose()
    }
    
    func enterAmountDidTapPaymentMethod() {
        router?.attachCardOnFile(paymentMethods: paymentMethods)
    }
    
    func enterAmountDidFinishTopup() {
        listener?.topupDidFinish()
    }
    
    func cardOnFileDidTapClose() {
        router?.detachCardOnFile()
    }
    
    func cardOnFileDidTapAddCard() {
        // attach add card
        router?.attachAddPaymentMethod(closeButtonType: .back)
    }
    func cardOnFileDidSelect(at index: Int) {
        if let selected = paymentMethods[safe: index] {
            dependency.paymentMethodStream.send(selected)
        }
        router?.detachCardOnFile()
    }
}
