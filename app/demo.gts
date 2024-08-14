// Re: https://github.com/emberjs/core-notes/pull/601#discussion_r1716695721

import 'ember-source/types';
import '@glint/environment-ember-loose';

import GC from '@glimmer/component';
import EC from '@ember/component';
import { ComponentLike } from '@glint/template';
import { resolve, yieldToBlock, templateForBackingValue, emitComponent, NamedArgsMarker } from '@glint/environment-ember-loose/-private/dsl';

////////////////////////////////////////////////////////////////////////////////////////////
// We set two components, one with the Glimmer base class and one with the Ember one
class Glimmer extends GC<{ Args: { name: string; age?: number } }> {}
class Ember extends EC<{ Args: { name: string } }> {}

////////////////////////////////////////////////////////////////////////////////////////////
// We set up a component that accepts something ComponentLike as long as it's invokable
// with just a `@name` string arg. Note that if we changed that by e.g. making `age` in
// the Ember component's signature required, it would no longer be legal to pass that
// component as a value to `@component`.
class AcceptsAndYieldsAComponent<T extends ComponentLike<{ Args: { name: string } }>> extends GC<{
  Args: { component: T };
  Blocks: {
    default: [theComponent: T];
  }
}> {}

////////////////////////////////////////////////////////////////////////////////////////////
// The given `@component` arg is invokable within `AcceptsAndYieldsAComponent`'s own
// template as long as a `@name` string is given, and is yieldable to the default block.
templateForBackingValue(AcceptsAndYieldsAComponent, (ctx) => {
  // <@component @name="Hello" />
  emitComponent(resolve(ctx.args.component)({ name: 'hi', ...NamedArgsMarker }));

  // {{yield @component}}
  yieldToBlock(ctx, 'default')(ctx.args.component);
});


////////////////////////////////////////////////////////////////////////////////////////////
// Any `ComponentLike` with a compatible signature is accepted, but the precise type of the
// given `@component` arg is preserved in the yielded output.
<template>

</template>

{
  // <AcceptsAndYieldsAComponent @component={{Glimmer}} as |component|>
  const { blockParams } = emitComponent(resolve(AcceptsAndYieldsAComponent)({
    component: Glimmer,
    ...NamedArgsMarker
  }));

  const component: typeof Glimmer = blockParams.default[0];
}
{
  // <AcceptsAndYieldsAComponent @component={{Ember}} as |component|>
  const { blockParams } = emitComponent(resolve(AcceptsAndYieldsAComponent)({
    component: Ember,
    ...NamedArgsMarker
  }));

  const component: typeof Ember = blockParams.default[0];
}