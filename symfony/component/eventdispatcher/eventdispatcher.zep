namespace Symfony\Component\EventDispatcher;

/**
 * The EventDispatcherInterface is the central point of Symfony's event listener system.
 *
 * Listeners are registered on the manager and events are dispatched through the
 * manager.
 *
 * @author  Guilherme Blanco <guilhermeblanco@hotmail.com>
 * @author  Jonathan Wage <jonwage@gmail.com>
 * @author  Roman Borschel <roman@code-factory.org>
 * @author  Bernhard Schussek <bschussek@gmail.com>
 * @author  Fabien Potencier <fabien@symfony.com>
 * @author  Jordi Boggiano <j.boggiano@seld.be>
 * @author  Jordan Alliot <jordan.alliot@gmail.com>
 * @author  Damien Alexandre <dalexandre@jolicode.com>
 *
 * @api
 */
class EventDispatcher implements \Symfony\Component\EventDispatcher\EventDispatcherInterface
{
    private $listeners;
    protected $sorted;

    public function __construct()
    {
        let $this->listeners = [];
        let $this->sorted = [];
    }

    /**
     * @see EventDispatcherInterface::dispatch
     *
     * @api
     */
    public function dispatch(string $eventName, <\Symfony\Component\EventDispatcher\Event> $event = null) -> <Symfony\Component\EventDispatcher\Event>
    {
        if ($event === null) {
            let $event = new \Symfony\Component\EventDispatcher\Event();
        }

        $event->setDispatcher($this);
        $event->setName($eventName);

        //var_dump($this->getListeners($eventName));die();

        if !isset $this->listeners[$eventName] {
            return $event;
        }


        $this->doDispatch($this->getListeners($eventName), $eventName, $event);

        return $event;
    }

    /**
     * @see EventDispatcherInterface::getListeners
     */
    public function getListeners(string $eventName = null)
    {
        var arrayEventName, event;

        if ($eventName !== null) {
            if !isset $this->sorted[$eventName] {
                $this->sortListeners($eventName);
            }
            return $this->sorted[$eventName];
        }

        for arrayEventName, event in $this->listeners {
            if !isset $this->sorted[arrayEventName] {
                $this->sortListeners(arrayEventName);
            }
        }

        return $this->sorted;
    }

    /**
     * @see EventDispatcherInterface::hasListeners
     */
    public function hasListeners($eventName = null) -> boolean
    {
        return count($this->getListeners($eventName)) > 0;
    }

    /**
     * @see EventDispatcherInterface::addListener
     *
     * @api
     */
    public function addListener(string $eventName, $listener, int $priority = 0) -> void
    {
        if !isset $this->listeners[$eventName] {
            let $this->listeners[$eventName] = [];
        }

        if !isset $this->listeners[$eventName][$priority] {
            let $this->listeners[$eventName][$priority] = [];
        }

        let $this->listeners[$eventName][$priority][] = $listener;
        
        if isset $this->sorted[$eventName] {
            //let $this->sorted[$eventName] = [];
            unset($this->sorted[$eventName]);
        }
    }

    /**
     * @see EventDispatcherInterface::removeListener
     */
    public function removeListener($eventName, $listener) -> void
    {
        var $key, $priority, $listeners;

        if !isset $this->listeners[$eventName] {
            return;
        }

        for $priority, $listeners in $this->listeners[$eventName] {
            let $key = array_search($listener, $listeners, true);
            if ($key !== false) {
                //var_dump($eventName, $priority, $key);
                //unset($this->listeners[$eventName][$priority][$key]);
                //unset($this->sorted[$eventName]);
                let $this->listeners[$eventName][$priority][$key] = [];
                let $this->sorted[$eventName] = [];
            }
        }
    }

    /**
     * @see EventDispatcherInterface::addSubscriber
     *
     * @api
     */
    public function addSubscriber(<\Symfony\Component\EventDispatcher\EventSubscriberInterface> $subscriber)
    {
        var $eventName, $params, $listener;

        for $eventName, $params in $subscriber->getSubscribedEvents() {
            if (is_string($params)) {
                $this->addListener($eventName, [$subscriber, $params]);
            } else {
                if (is_string($params[0])) {
                    $this->addListener($eventName, [$subscriber, $params[0]], (isset $params[1] ? $params[1] : 0));
                } else {
                    for $listener in $params {
                        $this->addListener($eventName, [$subscriber, $listener[0]], (isset $listener[1] ? $listener[1] : 0));
                    }
                }
            }
        }
    }

    /**
     * @see EventDispatcherInterface::removeSubscriber
     */
    public function removeSubscriber(<\Symfony\Component\EventDispatcher\EventSubscriberInterface> $subscriber)
    {
        var $eventName, $params, $listener;

        for $eventName, $params in $subscriber->getSubscribedEvents() {
            if (is_array($params) && is_array($params[0])) {
                for $listener in $params {
                    $this->removeListener($eventName, [$subscriber, $listener[0]]);
                }
            } else {
                $this->removeListener($eventName, [$subscriber, (is_string($params) ? $params : $params[0])]);
            }
        }
    }

    /**
     * Triggers the listeners of an event.
     *
     * This method can be overridden to add functionality that is executed
     * for each listener.
     *
     * @param callable[] $listeners The event listeners.
     * @param string     $eventName The name of the event to dispatch.
     * @param Event      $event     The event object to pass to the event handlers/listeners.
     */
    protected function doDispatch($listeners, $eventName, <\Symfony\Component\EventDispatcher\Event> $event)
    {
        var $listener;
        for $listener in $listeners {
            if !empty($listener) {
                call_user_func($listener, $event, $eventName, $this);
            }
            if ($event->isPropagationStopped()) {
                break;
            }
        }
    }

    /**
     * Sorts the internal list of listeners for the given event by priority.
     *
     * @param string $eventName The name of the event.
     */
    protected function sortListeners(string $eventName) -> void
    {
        let $this->sorted[$eventName] = [];

        if isset $this->listeners[$eventName] && !empty $this->listeners[$eventName] {
            krsort($this->listeners[$eventName]);

            // THERE IS AN ERROR HERE, we get sometime a listener            
            let $this->sorted[$eventName] = call_user_func_array("array_merge", $this->listeners[$eventName]);
        }
    }
}
